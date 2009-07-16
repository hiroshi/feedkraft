module SubscriptionsHelper
  def subscription_link(filter)
    return if filter.new_record?
    if current_user && key = filter.subscription_key
      link_to(image_tag("feedicons/14x14.png"), subscription_path(key), :title => "subscription feed") + " " +
        link_to(image_tag("unsubscribe14x14.png"), unsubscribe_path(key), :method => "delete", :title => "unsubscribe")
    else
      link_to image_tag("subscribe14x14.png"), subscriptions_path(:subscription => {:filter_id => filter.id}), :method => "post", :title => "subscribe"
    end
  end
end
