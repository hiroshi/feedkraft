module FiltersHelper
  
  def filter_key_options(feed, selected=nil)
    entry_tag = feed.entries_xpath.split("/").last

    options = ([selected] + feed.filter_fields.keys).uniq.compact.sort.map do |key|
      case key
      when /^@(.+)$/
        [$1, key]
      when /^[^@]+@/
        tags, attr = key.split("@")
        tags = tags.split("/")
        last = tags.pop
        [tags.map{|tag|"<#{tag}>"}.join + "<#{last} #{attr}>", key]
      else
        [key.split("/").map{|tag|"<#{tag}>"}.join, key]
      end
    end
    grouped_options_for_select({"<#{entry_tag}>" => options}, selected)
  end
end
