# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password # Scrub sensitive parameters from your log

  class ForbiddenError < Exception; end
  class NotFoundError < Exception; end

  def filter_params
    params.reject{|k,v|request.path_parameters[k]}
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
    end
  end
  def set_current_user(user)
    reset_session
    session[:user_id] = user && user.id
  end

  def set_feeds
    unless params[:url].blank?
      # sample: src = http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml
      uri = URI.parse(params[:url])
      if Rails.env == "development" && uri.relative?
        src = File.read(File.join(Rails.root,uri.to_s))
      else
        src = Net::HTTP.get_response(URI.parse(params[:url])).body
      end
      @src_feed = Feed.parse(src)
      @result_feed = Feed.parse(src)
      @result_feed.filter!(filter_params)
    end
  rescue SocketError => e
    flash[:error] = e.message
    redirect_to root_path(filter_params)
    false
  end
 
  helper_method :filter_params, :current_user
end
