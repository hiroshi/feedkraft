class FiltersController < ApplicationController
  before_filter :login_required, :only => [:create, :update, :destroy]
  before_filter :new_filter, :only => [:new, :create]
  before_filter :set_filter, :only => [:show, :update, :destroy] #, :feed]
  before_filter :author_required, :only => [:update, :destroy]
  before_filter :set_feeds, :only => [:new, :show] #, :feed]

  def latest
    # NOTE: Results must includes items at least a day before.
    # NOTE: Because of feed readers possibly retrieve once a day (or maybe more large span, but omit them).
    # NOTE: However, on the top page, they sould be limited to fixed number without date time condition.
    count = ::Filter.latest(:conditions => ["filters.created_at > ?", 1.day.ago]).count
    if count < 100 # less than 100, grab 100s no matter how they are old
      @filters = ::Filter.latest(:limit => 100)
    else # enough amount per day
      @filters = ::Filter.latest(:conditions => ["filters.created_at > ?", 1.day.ago]).all
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
    if current_user
      @filter = current_user.filters.build(params[:filter])
    else
      @filter = ::Filter.new(params[:filter])
    end
  end

  def set_filter
    @filter = ::Filter.with_subscription_key_for(current_user).find_by_id(params[:id]) or raise NotFoundError
  end

  def author_required
    raise ForbiddenError, "author required" unless current_user == @filter.user
  end
end
