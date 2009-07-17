# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password # Scrub sensitive parameters from your log

  class HttpError < Exception; end
  class BadRequestError < HttpError; def status; 400; end; end
  class ForbiddenError < HttpError; def status; 403; end; end
  class NotFoundError < HttpError; def status; 404; end; end

  class FeedSourceUnavailableError < Exception; end

  def filter_params
    unless @filter_params
      @filter_params = params.reject{|k,v|request.path_parameters[k]}
      if @filter && @filter_params.blank?
        @filter_params = @filter.params
      end
    end
    @filter_params
  end

  # == login user
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
    end
  end
  def set_current_user(user)
    reset_session
    session[:user_id] = user && user.id
  end
  def login_required
    #raise ForbiddenError, "login required" unless current_user
    unless current_user
      flash[:error] = "Login required"
      if request.get?
        session[:return_to] = request.uri
      else
        session[:return_to] = request.referer
      end
      redirect_to new_session_path
    end
  end

  def set_feeds
    require "open-uri"
    unless filter_params[:url].blank?
      @src_feed = Feed.open(filter_params[:url])
      @result_feed = Feed.open(filter_params[:url])

      @result_feed.filter!(filter_params.except(:url))
      if @filter
        @result_feed.title = @filter.title
      end
    end
  rescue Errno::ENOENT, SocketError, OpenURI::HTTPError, Feed::FeedError => e
    Rails.logger.debug e.message
    raise BadRequestError, e.message.mb_chars[0..1024] # because of common limitation of cookies are 4K
  end

  rescue_from NotFoundError, BadRequestError, ForbiddenError do |e|
    flash.now[:error] = e.message
    render :inline => <<-INLINE, :layout => true, :status => e.status
      <%= link_to "back", request.referer unless request.referer.blank? %>
    INLINE
  end

  helper_method :filter_params, :current_user
end
