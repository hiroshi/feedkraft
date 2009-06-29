class Feed
  def self.parse(src)
    doc = REXML::Document.new(src)
    case doc.root.name
    when "RDF" # RSS 1.0
      RSS1::Feed.new(doc)
    when "rss" # RSS 2.0
      RSS2::Feed.new(doc)
    when "feed" # Atom
      Atom::Feed.new(doc)
    end
  end

  def to_s
    @doc.to_s
  end

  def entries
    entry_class = self.class.to_s.sub(/Feed/,"Entry").constantize # TODO: any better awy?
    @entries ||= @doc.get_elements(self.entries_xpath).map {|e| entry_class.new(e) }
  end

  def filter!(params={})
    @entries = nil

    condition = params.map do |key, val|
      filter_case(key.to_sym, val)
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

    def title
      @doc.get_text("/rdf:RDF/channel/title").to_s.strip
    end

    def entries_xpath
      "/rdf:RDF/item"
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

    def title
      @doc.get_text("/rss/channel/title").to_s.strip
    end

    def entries_xpath
      "/rss/channel/item"
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

    def title
      @doc.get_text("/feed/title").to_s.strip
    end

    def entries_xpath
      "/feed/entry"
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

