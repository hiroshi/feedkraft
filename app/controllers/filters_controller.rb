class FiltersController < ApplicationController
  before_filter :login_required, :only => [:create, :update, :destroy]
  before_filter :new_filter, :only => [:new, :create]
  before_filter :set_filter, :only => [:show, :update, :destroy] #, :feed]
  before_filter :author_required, :only => [:update, :destroy]
  before_filter :set_feeds, :only => [:new, :show] #, :feed]
  
#  respond_to :atom, :only => :latest
  
  def latest
    # NOTE: Results must includes items at least a day before.
    # NOTE: Because of feed readers possibly retrieve once a day (or maybe more large span, but omit them).
    # NOTE: However, on the top page, they sould be limited to fixed number without date time condition.
    count = ::Filter.latest.where(["filters.created_at > ?", 1.day.ago]).count
    if count < 100 # less than 100, grab 100s no matter how they are old
      @filters = ::Filter.latest.limit(100)
    else # enough amount per day
      @filters = ::Filter.latest.where(["filters.created_at > ?", 1.day.ago]).all
    end
    respond_to do |format|
      format.atom
    end
  end

  def new
    raise BadRequestError, "Please enter a feed URL" if @src_feed.nil?
    @filter.title ||= @src_feed.title
  end

  def create
    if @filter.save
      redirect_to root_path
    else
      set_feeds
      render :action => "new"
    end
  end

  def show
    render :action => "new"
  end

  def update
    @filter.attributes = params[:filter]
    if @filter.save
      redirect_to root_path
    else
      set_feeds
      render :action => "new"
    end
  end

  def destroy
    @filter.destroy
    redirect_to root_path
  end

#   def feed
#     @result_feed.title = @filter.title
#     send_data @result_feed.to_s, :type => "text/xml; charset=UTF-8"
#   end

  private

  def new_filter
    # excludes utf8, the snowman param from params_string
    if new_filter_params = params[:filter]
      new_filter_params[:params_string] = Rack::Utils::build_query(Rack::Utils::parse_query(new_filter_params[:params_string]).except("utf8"))
    end
    if current_user
      @filter = current_user.filters.build(new_filter_params)
    else
      @filter = ::Filter.new(new_filter_params)
    end
  end

  def set_filter
    @filter = ::Filter.with_subscription_key_for(current_user).find_by_id(params[:id]) or raise NotFoundError
  end

  def author_required
    raise ForbiddenError, "author required" unless current_user == @filter.user
  end

  def set_feeds
    unless filter_params[:url].blank?
      # exceptional replacement for Safari's "feed" scheme
      if normalized_url = Feed.normalize_url(filter_params[:url])
        redirect_to :url => normalized_url
        return false
      end

      @src_feed = Feed.open(filter_params[:url])
      @result_feed = Feed.open(filter_params[:url])

      @result_feed.filter!(filter_params.except(:url))
      if @filter
        @result_feed.title = @filter.title
      end
    end
  rescue Feed::FeedError => e
    Rails.logger.debug e.message
    raise BadRequestError, e.message.mb_chars[0..1024] # because of common limitation of cookies are 4K
  end
end
