module SubscriptionsHelper
  def subscription_link(filter)
    # TODO: Don't find here
#    if subscription = filter.subscriptions.first(:conditions => {:filter_id => filter.id, :user_id => current_user.id})
#    if current_user && subscription = filter.subscriptions.first
    if current_user && key = filter.subscription_key
      link_to(image_tag("feedicons/14x14.png"), subscription_path(key), :title => "subscription feed") + " " +
        link_to(image_tag("unsubscribe14x14.png"), unsubscribe_path(key), :method => "delete", :title => "unsubscribe")
    else
      link_to image_tag("subscribe14x14.png"), subscriptions_path(:subscription => {:filter_id => filter.id}), :method => "post", :title => "subscribe"
    end
  end
end
