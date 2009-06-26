ActionController::Routing::Routes.draw do |map|
  map.root :controller => "feeds"
  map.feed "feed", :controller => "feeds", :action => "feed"

  map.resource :session, :only => [:new], :member => {:inquire => :post, :identify => :get}
end
