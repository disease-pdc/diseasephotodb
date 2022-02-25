class UsersController < ApplicationController

  before_action :require_admin

  def index
    @users = User.all.order("email asc")
  end

  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def update
    @user = User.find params[:id]
    if @user.update user_params
      flash.notice = "User updated"
      return redirect_to action: 'index'
    else
      return render action: 'show'
    end
  end

  def create
    @user = User.new user_params
    if @user.save
      flash.notice = "User created"
      return redirect_to action: 'index'
    else
      return render action: 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :admin, :image_viewer, :image_admin, :grader, :active)
    end

end