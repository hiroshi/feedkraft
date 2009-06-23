module RSS1
  class Entry
    def initialize(element)
      @element = element
    end

    def identity
      @element.attributes["rdf:about"].to_s
    end

    def title
      @element.get_text("title").to_s
    end

    def link
      @element.get_text("link").to_s
    end
  end
end

module RSS2
  class Entry
    def initialize(element)
      @element = element
    end

    def identity
      %w(guid link title).map{|name| @element.get_text(name) }.compact.first.to_s
    end

    def title
      @element.get_text("title").to_s
    end

    def link
      @element.get_text("link").to_s
    end
  end
end

module Atom
  class Entry
    def initialize(element)
      @element = element
    end

    def identity
      @element.get_text("id").to_s
    end

    def title
      @element.get_text("title").to_s
    end

    def link
      @element.elements["link[@rel='alternate']"].attributes["href"]
    end
  end
end

class Feed
  def initialize(src)
    @doc = REXML::Document.new(src)
  end

  def entries
    case @doc.root.name
    when "RDF" # RSS 1.0
      @entries ||= @doc.get_elements("/rdf:RDF/item").map {|e| RSS1::Entry.new(e) }
    when "rss" # RSS 2.0
      @entries ||= @doc.get_elements("/rss/channel/item").map {|e| RSS2::Entry.new(e) }
    when "feed" # Atom
      @entries ||= @doc.get_elements("/feed/entry").map {|e| Atom::Entry.new(e) }
    end
  end

  def filter!(options={})
    key, val = options.shift
    @doc.elements.delete_all "//item[not(contains(@#{key},'#{val}'))]"
  end

  def to_s
    @doc.to_s
  end
end
