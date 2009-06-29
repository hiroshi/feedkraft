class FiltersController < ApplicationController
  before_filter :new_filter, :only => [:new, :create]
  before_filter :set_filter, :only => [:show, :update]
  before_filter :set_feeds, :only => [:new, :show]

  def new
    @filter.name ||= @src_feed.title
  end

  def create
    if @filter.save
      render :action => "new"
    else
      redirect_to filter_path(@filter)
    end
  end

  def show
    render :action => "new"
  end

  private

  def new_filter
    if current_user
      @filter = current_user.filters.build(params[:filter])
    else
      @filter = ::Filter.new(params[:filter])
    end
  end

  def set_filter
    @filter = ::Filter.find_by_id(params[:id]) or raise NotFoundError
  end
end
