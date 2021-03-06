require "rexml/document"

# extends XPath functions
module REXML
  module Functions
    # same as contains but case-insensitive manner
    def Functions::containsi(string, test)
      # string(string).include?(string(test)) # original
      !!(string(string) =~ /#{Regexp.escape(string(test))}/i)
    end
  end
end

class Entry
  # define reader method for child elements or attributes
  def self.child_reader(*args)
    case args.first
    when Symbol, String
      name, xpath = args.first.to_sym, args.first.to_s
    when Hash
      name, xpath = args.first.to_a.first
    end

    define_method name do
      e = @element.get_elements(xpath).first
      (e.cdatas.first || e.texts.first).to_s
    end
  end
end

class Feed
  class FeedError < RuntimeError; end
  class InvalidURLError < FeedError; end
  class InvalidConnectionError < FeedError; end
  class InvalidContentError < FeedError; end

  def self.normalize_url(url)
    url = url.dup
    url.sub!(/^feed:\/\//, "http://")
  end

  def self.open(url_or_path)
    require "open-uri"
    uri = URI.parse(url_or_path)
    # cache feed
    cache_key = Digest::SHA1.hexdigest(uri.to_s)
    cache_path = Rails.root.join("tmp", "cache", "feeds", cache_key)
    if cache_path.exist? && (cache_path.mtime + FeedKraft[:feed_cache_expires]) > Time.now
      # on cache
      src = cache_path.read
      Rails.logger.info "Feed cache read: #{uri.to_s}"
      Feed.parse(src)
    else
      # out of cache
      src = nil
      ms = Benchmark.ms do
        if Rails.env != "production" && uri.relative?
          # local file (for development/test)
          src = File.read(File.join(Rails.root, uri.to_s))
        else
          # URL
          if uri.respond_to?(:open)
            begin
              src = uri.open{|io| io.read }
            rescue SocketError, EOFError, Timeout::Error => e
              raise InvalidConnectionError, e.to_s
            rescue OpenURI::HTTPError, Errno::ECONNREFUSED => e
              raise InvalidURLError, e.to_s
            end
          else
            raise InvalidURLError, "Invalid URL: #{uri.to_s}"
          end
        end
      end
      cache_path.dirname.mkpath
      cache_path.open("w") {|file| file.print src }
      Rails.logger.info "Feed cache write (%.1fms): #{uri.to_s}" % [ms]
      Feed.parse(src)
    end
  rescue FeedError => e
    raise e.class, e.message + ": #{url_or_path}"
  end

  def self.parse(src)
    # dereferencing numerical caracter references. Why bother?
    # 1. options_for_select does html_escape without choice, so '&' is going to be decoded.
    # 2. It will be complex dereference everytime before comparing with filter condition values.
    src = src.gsub(/&#(\d+);/){|u| [$1.to_i].pack("U")}

    doc = REXML::Document.new(src)
    raise InvalidContentError, "No XML root" if doc.root.nil?
    case doc.root.expanded_name
    when "rdf:RDF" # RSS 1.0
      RSS1::Feed.new(doc)
    when "rss" # RSS 2.0
      RSS2::Feed.new(doc)
    when "feed" # Atom
      Atom::Feed.new(doc)
    else
      raise InvalidContentError, "Not a feed"
    end
  rescue REXML::ParseException => e
    raise InvalidContentError, e.message
  end

  def to_s
    @doc.to_s
  end

  def title
    @doc.get_text(self.title_xpath).to_s.strip
  end

  def title=(text)
    @doc.get_elements(self.title_xpath).first.text = text
  end

  def entries
    unless @entries
      entry_class = self.class.to_s.sub(/Feed/,"Entry").constantize # TODO: another better awy?
      @entries = @doc.get_elements(self.entries_xpath).map {|e| entry_class.new(e) }
    end
    @entries
  end

  def filter_fields
    unless @filter_fields
      hash = {}
      self.entries.each do |entry|
        element = entry.instance_variable_get("@element")
        update_filter_field(hash, nil, element)
      end
      hash.each_value {|v| v.uniq!}
      # NOTE: An ordered hash created with OrderedHash[] causes error when #keys are called.
      # NOTE: It happens with rails 2.3.2
      # NOTE: The fix is committed: http://github.com/rails/rails/commit/2bcb2443a9e2140e29799229d6c63a046e149597
      # @filter_fields = ActiveSupport::OrderedHash[*hash.sort.inject([]){|a,pair|a+=pair}]
      @filter_fields = hash.sort.inject(ActiveSupport::OrderedHash.new){|h,pair|h[pair.first] = pair.last;h}
    end
    @filter_fields
  end

  def update_filter_field(hash, path, element)
    element.attributes.each do |name,val|
      (hash["#{path}@#{name}"] ||= []) << val
    end
    if element.has_elements?
      element.elements.each do |e|
        update_filter_field(hash, [path, e.expanded_name].compact.join("/"), e)
      end
    elsif element.has_text?
      (hash[path] ||= []) << (element.cdatas.first || element.texts.first).to_s.strip
    end
  end
  private :update_filter_field

  def filter!(params={})
    params = params.clone
    @entries = nil

    allow_all = params.delete("!all") == "deny" ? false : true

    condition = params.map do |key, val|
      vals = Feed.split_value(val)

      case key
      when /^@/ # an attribute of entries
        exp = vals.map{|val| "containsi(#{key},'#{val}')" }.join(" or ")
        "(#{exp})"
      when /^[^@]+@/ # an attribute of a child element of entries
        tag, attr = key.split("@")
        exp = vals.map{|val| "containsi(@#{attr},'#{val}')" }.join(" or ")
        "#{tag}[#{exp}]"
      else # child of entry (e.g. <entry>...<category>Rails</category>...</entry>)
        exp = vals.map{|val| "containsi(normalize-space(text()),'#{val}')" }.join(" or ")
        "#{key}[#{exp}]"
      end
    end.compact.join(" and ")

    unless condition.blank?
      if allow_all
        xpath = "#{entries_xpath}[not(#{condition})]"
      else # deny all
        xpath = "#{entries_xpath}[#{condition}]"
      end
      result = nil
      ms = Benchmark.ms { @doc.elements.delete_all xpath }
      Rails.logger.debug "#{self.class.name}:filter! (%.1fms) #{xpath}" % [ms]
    end
  rescue
    Rails.logger.debug "#{self.class.name}:filter! #{params.inspect} => #{xpath}"
    raise
  end

  # Split string value with comma like CSV
  # Why parse by hand? Because CSV, FasterCSV nor YAML.load doesn't work for me
  def self.split_value(value)
    values = [""]
    quote = nil
    value.each_char do |c|
      if quote.nil? && c == ',' # ignore ',' in quotes
        values << ""
      else
        if ['"',"'"].include?(c)
          quote = quote ? nil : c
        end
        values.last << c
      end
    end
    values.map(&:strip).map{|v| v.gsub(/["']/,"")} # strip white space and quotes
  end
end

module RSS1
  class Entry < ::Entry
    child_reader :title
    child_reader :content => "description"
    child_reader :link

    def initialize(element)
      @element = element
    end

    def categories
      []
    end
  end

  class Feed < ::Feed
    def initialize(doc)
      @doc = doc
    end

    def title_xpath
      "/rdf:RDF/channel/title"
    end

    def entries_xpath
      "/rdf:RDF/item"
    end
  end
end

module RSS2
  class Entry < ::Entry
    child_reader :title
    child_reader :content => "description"
    child_reader :link

    def initialize(element)
      @element = element
    end

    def categories
      @element.get_elements("category").map{|c| c.text.strip }
    end
  end

  class Feed < ::Feed
    def initialize(doc)
      @doc = doc
    end

    def title_xpath
      "/rss/channel/title"
    end

    def entries_xpath
      "/rss/channel/item"
    end
  end
end

module Atom
  class Entry < ::Entry
    child_reader :title
    child_reader :content

    def initialize(element)
      @element = element
    end

    def link
      @element.elements["link[@rel='alternate']"].attributes["href"]
    end

    def categories
      @element.get_elements("category").map{|c| c.attributes["term"] }
    end
  end

  class Feed < ::Feed
    def initialize(doc)
      @doc = doc
    end

    def title_xpath
      "/feed/title"
    end

    def entries_xpath
      "/feed/entry"
    end
  end
end

