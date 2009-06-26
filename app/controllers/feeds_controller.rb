class FeedsController < ApplicationController
  before_filter :set_feeds

  def index
  end

  def feed
    send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
  end

  def auth
    require "openid"
    require 'openid/store/filesystem'

    store = OpenID::Store::Filesystem.new(Rails.root.join("db").join("cstore"))
    consumer = OpenID::Consumer.new(session, store)
    oidreq = consumer.begin("https://www.google.com/accounts/o8/id")
    redirect_to oidreq.redirect_url(root_url, identify_session_url)
  end

  def complete
    require "openid"
    require 'openid/store/filesystem'

    store = OpenID::Store::Filesystem.new(Rails.root.join("db").join("cstore"))
    consumer = OpenID::Consumer.new(session, store)

    oidresp = consumer.complete(params.reject{|k,v|request.path_parameters[k]}, complete_url)
    case oidresp.status
    when OpenID::Consumer::SUCCESS
      flash[:success] = ("Verification of #{oidresp.display_identifier} succeeded.")
      # TODO: store session
    when OpenID::Consumer::FAILURE
      if oidresp.display_identifier
        flash[:error] = ("Verification of #{oidresp.display_identifier} failed: #{oidresp.message}")
      else
        flash[:error] = "Verification failed: #{oidresp.message}"
      end
    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    end
    redirect_to root_path
  end

  private

  def set_feeds
    unless params[:src].blank?
      # sample: src = http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml
      uri = URI.parse(params[:src])
      if Rails.env == "development" && uri.relative?
        src = File.read(File.join(Rails.root,uri.to_s))
      else
        src = Net::HTTP.get_response(URI.parse(params[:src])).body
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
end
