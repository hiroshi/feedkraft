class FeedsController < ApplicationController
  # sample: src = http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml
  before_filter :set_feeds

  def index
    unless params[:src].blank?
      src = Net::HTTP.get_response(URI.parse(params[:src])).body
      @src_feed = Feed.new(src)
      @result_feed = Feed.new(src)
      @result_feed.filter!("rdf:about" => params[:rdf_about])
    end
  end

  def feed
    send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
#     # TODO: Of course, need refactoring
# #     # doc = REXML::Document.new(open("mycom.xml"))
#     doc = REXML::Document.new(Net::HTTP.get_response(URI.parse(params[:src])).body)
#     doc.elements.delete_all "//item[not(contains(@rdf:about,'#{params[:rdf_about]}'))]"
#     send_data doc.to_s, :type => "text/xml; charset=UTF-8"
# #    render :nothing => true
#   rescue SocketError => e
#     flash[:error] = e.message
#     redirect_to root_path(params)
  end

  private

  def set_feeds
    unless params[:src].blank?
      src = Net::HTTP.get_response(URI.parse(params[:src])).body
      @src_feed = Feed.new(src)
      @result_feed = Feed.new(src)
      @result_feed.filter!("rdf:about" => params[:rdf_about])
    end
  rescue SocketError => e
    flash[:error] = e.message
    redirect_to root_path(params)
    false
  end
end
