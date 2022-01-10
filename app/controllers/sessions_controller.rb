class SessionsController < ApplicationController

  def new

  end

  def send_login
    user = User.find_by email: params[:email]
    if user
      token = user.create_login_token!
      LoginMailer.with(user: user, token: token).login_email.deliver_now
    else
      @errors = ["Unable to find email"]
      render action: 'new'
    end
  end

  def create
    @user = User.by_email_token params[:email], params[:token]
    if @user
      session[:user_id] = @user.id
      redirect_to controller: 'home'
    else
      @errors = ["Login token expired"]
      render action: 'new'
    end
  end

  def delete
    session.destroy
    redirect_to controller: 'home'
  end

end
