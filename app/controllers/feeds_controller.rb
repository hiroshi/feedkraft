class FeedsController < ApplicationController
  before_filter :set_feeds, :only => [:feed]

  def index
    @latest_filters = ::Filter.latest(:limit => 10).all
    @popular_filters = ::Filter.popular.all
  end

  def feed
    send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
  end
end
