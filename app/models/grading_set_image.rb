class GradingSetImage < ApplicationRecord

  belongs_to :image
  belongs_to :grading_set
  has_many :user_grading_set_images, dependent: :delete_all

  def complete_count
    user_grading_set_images.count
  end

  def complete?
    grading_set.users.count == complete_count
  end

end