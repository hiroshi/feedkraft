class FeedsController < ApplicationController
#  before_filter :set_feeds, :only => [:feed]

  def index
    @latest_filters = ::Filter.latest.with_subscription_key_for(current_user).all(:limit => 10)
    @popular_filters = ::Filter.popular(:with_subscription_key_for => current_user).all
  end

#   def feed
#     send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
#   end
end
