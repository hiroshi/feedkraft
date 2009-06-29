# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password # Scrub sensitive parameters from your log

  class ForbiddenError < Exception; end
  class NotFoundError < Exception; end

  class FeedSourceUnavailableError < Exception; end

  def filter_params
    if @filter_params.blank?
      @filter_params = params.reject{|k,v|request.path_parameters[k]}
      if @filter
        @filter_params.update(@filter.params)
      end
    end
    @filter_params
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
    require "open-uri"
    unless filter_params[:url].blank?
      # sample: src = http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml
      uri = URI.parse(filter_params[:url])
      if Rails.env == "development" && uri.relative?
        src = File.read(File.join(Rails.root,uri.to_s))
      else
        src = open(uri).read
      end
      @src_feed = Feed.parse(src)
      @result_feed = Feed.parse(src)
      @result_feed.filter!(filter_params)
    end
  rescue SocketError, Feed::InvalidContentError, OpenURI::HTTPError => e
    Rails.logger.debug e.message
    flash[:error] = e.message.mb_chars[0..1024] # because of common limitation of cookies are 4K
    redirect_to root_path(filter_params)
    false
  end

  helper_method :filter_params, :current_user
end
