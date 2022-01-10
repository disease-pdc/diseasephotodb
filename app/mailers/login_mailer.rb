class LoginMailer < ApplicationMailer

  def login_email
    @user = params[:user]
    @token = params[:token]
    mail to: @user.email, subject: "Access the TF Imagery Database"
  end

end
