class SubscriptionsController < ApplicationController
  before_filter :login_required, :only => [:create, :destroy]
  before_filter :set_subscription_and_filter, :only => [:feed, :destroy]
  before_filter :set_feed, :only => [:feed]

  def create
    @subscription = Subscription.create!(params[:subscription].merge(:user_id => current_user.id))
    redirect_to :back
  end

  def feed
    # @result_feed.title += " for #{current_user.name}"
    @subscription.update_attribute(:accessed_at, Time.now.utc)
    send_data @feed.to_s, :type => "text/xml; charset=UTF-8"
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

  def set_feed
    @feed = Feed.open(filter_params[:url])
    @feed.filter!(filter_params.except(:url))
    @feed.title = @filter.title
    # TODO: DRY rescue with filters#set_feeds
  rescue Errno::ENOENT, SocketError, OpenURI::HTTPError, Feed::FeedError => e
    Rails.logger.debug e.message
    raise BadRequestError, e.message.mb_chars[0..1024] # because of common limitation of cookies are 4K
  end
end
