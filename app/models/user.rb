class User < ApplicationRecord


  def self.by_email_token email, token
    user = User.find_by email: email
    if user && 
        token == BCrypt::Password.new(user.login_token_hash) &&
        DateTime.now < user.login_token_expires_at
      return user
    end
  end

  def create_login_token!
    token = SecureRandom.uuid
    token_hash = BCrypt::Password.create token
    exp = DateTime.now + 1.hour
    update! login_token_hash: token_hash, login_token_expires_at: exp
    return token_hash
  end

end
