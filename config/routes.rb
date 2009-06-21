ActionController::Routing::Routes.draw do |map|
  map.root :controller => "feeds"
  map.feed "feed", :controller => "feeds", :action => "feed"
end
