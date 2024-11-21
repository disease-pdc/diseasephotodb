class LoginMailer < ApplicationMailer

  def login_email
    @user = params[:user]
    @token = params[:token]
    mail to: @user.email, subject: "Access the FGS Imagery Database"
  end

end
