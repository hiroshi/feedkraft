ActionController::Routing::Routes.draw do |map|

  map.root :controller => "feeds", :conditions => {:method => :get}
#  map.feed "feed", :controller => "feeds", :action => "feed", :conditions => {:method => :get}
  map.resources :filters, :member => {:feed => :get}, :collection => {:latest => :get}, :except => [:edit]
#  map.feed_user_filter "users/:user_id/filters/:id/feed", :controller => "filters", :action => "feed", :conditions => {:method => :get}

  map.subscription "subscription/:key", :controller => "subscriptions", :action => "feed", :requirements => {:key => /[0-9a-f]{8}/i}, :conditions => {:method => :get}
  map.resources :subscriptions, :only => [:create]
  map.unsubscribe "subscription/:key", :controller => "subscriptions", :action => "destroy", :requirements => {:key => /[0-9a-f]{8}/i}, :conditions => {:method => :delete}

  map.resource :session, :only => [:new, :destroy], :member => {:inquire => :post, :identify => :get}
  map.resources :users, :only => [:edit, :update]
end
