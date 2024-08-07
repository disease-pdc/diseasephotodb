class User < ApplicationRecord

  scope :active, -> { where(active: true) }
  has_many :user_grading_sets
  has_many :user_grading_set_images

  validates 'email', presence: true, uniqueness: true

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

  def roles_string
    roles = []
    roles << "Admin" if admin?
    roles << "Image Admin" if image_admin?
    roles << "Image Viewer" if image_viewer?
    roles << "Grader" if grader?
    roles.join(", ")
  end

  def user_grading_set_for grading_set_id
    user_grading_sets.where(grading_set_id: grading_set_id).first
  end


end
