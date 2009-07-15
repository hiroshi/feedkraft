class SubscriptionsController < ApplicationController
  before_filter :login_required, :only => [:create, :destroy]
  before_filter :set_subscription_and_filter, :only => [:feed, :destroy]
  before_filter :set_feeds, :only => [:feed]

  def create
    @subscription = Subscription.create!(params[:subscription].merge(:user_id => current_user.id))
    redirect_to :back
  end

  def feed
    # @result_feed.title += " for #{current_user.name}"
    @subscription.update_attribute(:accessed_at, Time.now.utc)
    send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
  end

  def destroy
    @subscription.destroy
    redirect_to :back
  end

  private

  def set_subscription_and_filter
    @subscription = Subscription.find_by_key(params[:key]) or raise NotFoundError
    @filter = @subscription.filter
  end
end
