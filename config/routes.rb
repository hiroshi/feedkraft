Rails.application.routes.draw do
  root :to => "feeds#index", :via => :get
  get "bookmarklet.js", :to => "feeds#bookmarklet"
  
  resources :filters, :except => [:edit] do
    member do
      get :feed
    end
    collection do
      get :latest
    end
  end
  
  get "subscription/:key", :to => "subscriptions#feed", :constraints => {:key => /[0-9a-f]{8}/i}
  resources :subscriptions, :only => [:create]
  delete "subscription/:key", :to => "subscriptions#destroy", :constraints => {:key => /[0-9a-f]{8}/i}
  
  resource :session, :only => [:new, :destroy] do
    member do 
      post :inquire
      get :identify
    end
  end
  resources :users, :only => [:edit, :update]
end
