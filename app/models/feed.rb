class Feed
  class InvalidContentError < Exception; end

  def self.parse(src)
    doc = REXML::Document.new(src)
    case doc.root.expanded_name
    when "rdf:RDF" # RSS 1.0
      RSS1::Feed.new(doc)
    when "rss" # RSS 2.0
      RSS2::Feed.new(doc)
    when "feed" # Atom
      Atom::Feed.new(doc)
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
      (hash[path] ||= []) << element.get_text.to_s.strip
    end
  end
  private :update_filter_field

  def filter!(params={})
    @entries = nil

    condition = params.map do |key, val|
      #filter_case(key.to_sym, val)
      # "contains(@rdf:about,'#{val}')" # an attribute of entries
      # "category[@term='#{val}']" # an attribute of child elements
      # "category[normalize-space(text())='#{val}']" # text of child elements
      case key
      when /^@/ # attribute of entry
        "contains(#{key},'#{val}')" # an attribute of entries
      when /^[^@]+@/ # attribute of a child of entry
        tag, attr = key.split("@")
        "#{tag}[@#{attr}='#{val}']" # an attribute of child elements
      else # child of entry (e.g. <entry>...<category>Rails</category>...</entry>)
        "#{key}[contains(normalize-space(text()),'#{val}')]" # text of child elements
      end
    end.compact.join(" and ")

    unless condition.blank?
      xpath = "#{entries_xpath}[not(#{condition})]"
      result = nil
      ms = Benchmark.ms { @doc.elements.delete_all xpath }
      Rails.logger.debug "  #{self.class.name}:filter! (%.1fms) #{xpath}" % [ms]
    end
  rescue
    Rails.logger.debug "  #{self.class.name}:filter! #{params.inspect} => #{xpath}"
    raise
  end
end

class Entry
  def identifier_name
    self.class.identifier_name
  end
end

module RSS1
  class Entry < ::Entry
    def initialize(element)
      @element = element
    end

    def identifier
      @element.attributes["rdf:about"].to_s
    end

    def self.identifier_name
      "rdf:about"
    end

    def title
      @element.get_text("title").to_s
    end

    def link
      @element.get_text("link").to_s
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

    def content_tag_name
      "description"
    end

    def filter_case(key, val)
      case key
      when :identifier
        "contains(@rdf:about,'#{val}')"
      when :category
        # TODO: use dc:type?
      end
    end
  end
end

module RSS2
  class Entry < ::Entry
    def initialize(element)
      @element = element
    end

    def identifier
      #%w(guid link title).map{|name| @element.get_text(name) }.compact.first.to_s
      @element.get_text("guid").to_s
    end

    def self.identifier_name
      "guid"
    end

    def title
      @element.get_text("title").to_s
    end

    def link
      @element.get_text("link").to_s
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

    def content_tag_name
      "description"
    end

    def filter_case(key, val)
      case key
      when :identifier
        # FIXME
      when :category
        "category[normalize-space(text())='#{val}']"
      end
    end
  end
end

module Atom
  class Entry < ::Entry
    def initialize(element)
      @element = element
    end

    def identifier
      @element.get_text("id").to_s
    end

    def self.identifier_name
      "id"
    end

    def title
      @element.get_text("title").to_s
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

    def content_tag_name
      "content"
    end

    def filter_case(key, val)
      case key
      when :identifier
        # FIXME
      when :category
        "category[@term='#{val}']"
      end
    end
  end
end

