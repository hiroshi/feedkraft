# ;-*-Ruby-*-
xml.instruct!
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title "FeedKraft - latest filters"
  xml.link :href => root_url
  xml.updated Time.now.to_s(:rfc3339)
  xml.id root_url
  @filters.each do |filter|
    xml.entry do
      xml.title filter.title
      xml.id filter_url(filter)
      xml.link :type => "application/atom+xml", :href => feed_filter_url(filter)
      xml.link :rel => "alternate", :type => "text/html", :href => filter_url(filter)
      xml.published filter.created_at.to_s(:rfc3339)
      xml.updated filter.updated_at.to_s(:rfc3339)
      xml.author do
        xml.name "@#{filter.user.identifier}"
      end
    end
  end
end
