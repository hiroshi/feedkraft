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
    redirect_to root_path(filter_params)
    false
  end
end
