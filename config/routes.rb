ActionController::Routing::Routes.draw do |map|
  # map.resources :subscriptions, :only => []

  map.root :controller => "feeds"
  map.feed "feed", :controller => "feeds", :action => "feed"
  map.resources :filters, :member => {:feed => :get}, :collection => {:latest => :get}, :except => [:edit]
  map.feed_user_filter "/users/:user_id/filters/:id/feed", :controller => "filters", :action => "feed"

  map.resource :session, :only => [:new, :destroy], :member => {:inquire => :post, :identify => :get}
  map.resources :users, :only => [:edit, :update]
end
