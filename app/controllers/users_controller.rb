class UsersController < ApplicationController
  before_filter :set_user

  def edit
  end

  def update
    @user.attributes = params[:user]
    if @user.save
      redirect_to root_path
    else
      render :action => "edit"
    end
  end

  private

  def set_user
    # only for myself
    raise ForbiddenError if current_user.nil? || params[:id].to_i != current_user.id
    @user = User.find_by_id(params[:id]) or raise NotFoundError
  end
end
