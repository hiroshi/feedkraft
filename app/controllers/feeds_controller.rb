class FeedsController < ApplicationController
  before_filter :set_feeds

  def index
  end

  def feed
    send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
  end

  private

  def set_feeds
    unless params[:src].blank?
      # sample: src = http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml
      uri = URI.parse(params[:src])
      if Rails.env == "development" && uri.relative?
        src = File.read(File.join(Rails.root,uri.to_s))
      else
        src = Net::HTTP.get_response(URI.parse(params[:src])).body
      end
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
