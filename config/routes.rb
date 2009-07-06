ActionController::Routing::Routes.draw do |map|
  map.root :controller => "feeds"
  map.feed "feed", :controller => "feeds", :action => "feed"
  map.resources :filters, :member => {:feed => :get}, :collection => {:latest => :get}

  map.resource :session, :only => [:new, :destroy], :member => {:inquire => :post, :identify => :get}
  map.resources :users
end
