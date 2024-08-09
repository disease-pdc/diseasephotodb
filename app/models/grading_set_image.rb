class GradingSetImage < ApplicationRecord

  belongs_to :gradeable, polymorphic: true
  belongs_to :grading_set
  has_many :user_grading_set_images, dependent: :delete_all

  def complete_count
    user_grading_set_images.where('flipped = false').count
  end

  def complete_count_flipped
    user_grading_set_images.where('flipped = true').count
  end

  def complete_count_total
    user_grading_set_images.count
  end

  def complete?
    grading_set.users.count == complete_count
  end

  def name
    gradeable.name || gradeable.filename
  end

end