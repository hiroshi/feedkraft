class FeedsController < ApplicationController
  before_filter :set_feeds, :only => [:feed]

  def index
    @filters = ::Filter.latests(:limit => 10)
  end

  def feed
    send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
  end
end
