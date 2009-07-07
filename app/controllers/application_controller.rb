# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password # Scrub sensitive parameters from your log

  class ForbiddenError < Exception; end
  class NotFoundError < Exception; end
  class BadRequestError < Exception; end

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
      # cache feed
      cache_key = Digest::SHA1.hexdigest(uri.to_s)
      cache_path = Rails.root.join("tmp", "cache", "feeds", cache_key)
      if cache_path.exist? && (cache_path.mtime + FeedKraft[:feed_cache_expires]) > Time.now
        src = cache_path.read
        Rails.logger.info "Feed cache read: #{uri.to_s}"
      else
        src = nil
        ms = Benchmark.ms do
          if Rails.env == "development" && uri.relative?
            src = File.read(File.join(Rails.root, uri.to_s))
          else
            src = open(uri).read
          end
        end
        cache_path.dirname.mkpath
        cache_path.open("w") do |file|
          file.print src
        end
        Rails.logger.info "Feed cache write (%.1fms): #{uri.to_s}" % [ms]
      end

      @src_feed = Feed.parse(src)
      @result_feed = Feed.parse(src)
      @result_feed.filter!(filter_params.except(:url))
    end
  rescue SocketError, Feed::InvalidContentError, OpenURI::HTTPError => e
    Rails.logger.debug e.message
    #flash[:error] = e.message.mb_chars[0..1024] # because of common limitation of cookies are 4K
    #redirect_to root_path(filter_params)
    raise BadRequestError, e.message.mb_chars[0..1024] # because of common limitation of cookies are 4K
  end

  rescue_from NotFoundError, BadRequestError, ForbiddenError do |e|
    flash[:error] = e.message
    redirect_to root_path
  end

  helper_method :filter_params, :current_user
end
