class GradingSet < ApplicationRecord

  has_many :grading_set_images
  has_many :images, through: :grading_set_images

end
