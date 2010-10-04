class SessionsController < ApplicationController
  def new
    config = Rails.application.config.oauth
    client = TwitterOAuth::Client.new(config.slice(:consumer_key, :consumer_secret))
    request_token = client.request_token(config.slice(:oauth_callback))
    session[:oauth_token] = request_token.token
    session[:oauth_secret] = request_token.secret
    session[:return_to] = params[:return_to]
    redirect_to request_token.authorize_url
  end
  
  def oauth
    config = Rails.application.config.oauth
    client = TwitterOAuth::Client.new(config.slice(:consumer_key, :consumer_secret))
    # NOTE: TwitterOAuth::Client#authorize issues an http request to the OAuth server
    access_token = client.authorize(session[:oauth_token], session[:oauth_secret], :oauth_verifier => params[:oauth_verifier])
    session[:identifier] = access_token.params[:screen_name]
    user = User.find_or_create_by_identity(session[:identifier])
    redirect_to session.delete(:return_to) || root_path
    set_current_user(user)
  rescue Net::HTTPFatalError, OAuth::Unauthorized => e
    render :inline => "Twitter OAuth failed (#{e}).", :status => 401
  end
  
  # logout
  def destroy
    reset_session
    redirect_to root_path
  end
end
