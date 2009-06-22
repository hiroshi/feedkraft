class Feed
  class Item
    def initialize(element)
      @element = element
    end

    def rdf_about
      
    end

    def title
      @element.get_text("title").to_s
    end

    def link
      @element.get_text("link").to_s
    end
  end

  def initialize(src)
    @doc = REXML::Document.new(src)
  end

  def items
    @items ||= @doc.get_elements("//rdf:RDF/item").map {|e| Item.new(e) }
  end

  def filter!(options={})
    key, val = options.shift
    @doc.elements.delete_all "//item[not(contains(@#{key},'#{val}'))]"
  end

  def to_s
    @doc.to_s
  end
end
