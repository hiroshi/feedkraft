class FiltersController < ApplicationController
  before_filter :new_filter, :only => [:new, :create]
  before_filter :set_filter, :only => [:show, :update, :destroy]
  before_filter :set_feeds, :only => [:new, :show]

  def new
    @filter.title ||= @src_feed.title
  end

  def create
    if @filter.save
      redirect_to filter_path(@filter)
    else
      set_feeds
      render :action => "new"
    end
  end

  def show
    render :action => "new"
  end

  def destroy
    @filter.destroy
    redirect_to root_path
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
