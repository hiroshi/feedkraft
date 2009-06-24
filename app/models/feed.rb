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

    def entries
      @entries ||= @doc.get_elements("/rdf:RDF/item").map {|e| Entry.new(e) }
    end

    def filter!(options={})
      @entries = nil
      key, val = options.shift.map(&:to_s)
      case key
      when "identifier"
        unless val.blank?
          @doc.elements.delete_all "/rdf:RDF/item[not(contains(@rdf:about,'#{val}'))]"
        end
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

    def entries
      @entries ||= @doc.get_elements("/rss/channel/item").map {|e| Entry.new(e) }
    end

    def filter!(options={})
      @entries = nil
      key, val = options.shift.map(&:to_s)
      case key
      when "category"
        unless val.blank?
          @doc.elements.delete_all "/rss/channel/item[not(category[normalize-space(text())='#{val}'])]"
        end
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

    def entries
      @entries ||= @doc.get_elements("/feed/entry").map {|e| Entry.new(e) }
    end

    def filter!(options={})
      @entries = nil
      key, val = options.shift.map(&:to_s)
      case key
      when "category"
        unless val.blank?
          @doc.elements.delete_all "/feed/entry[not(category[@term='#{val}'])]"
        end
      end
    end
  end
end

