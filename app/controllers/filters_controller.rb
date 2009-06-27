class FiltersController < ApplicationController
  before_filter :set_feeds, :only => [:new]
  before_filter :new_filter, :only => [:new, :create]

  def new
  end

  def create
    if @filter.save
      render :action => "new"
    else
      redirect_to filter_path(@filter)
    end
  end

  def show
    @filter = ::Filter.find_by_id(params[:id]) or raise NotFoundError
  end

  private

  def new_filter
    if current_user
      @filter = current_user.filters.build(params[:filter])
    else
      @filter = ::Filter.new(params[:filter])
    end
  end
end
