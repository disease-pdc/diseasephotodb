class ImageSource < ApplicationRecord

  has_many :images

  validates 'name', presence: true, uniqueness: true

  def image_count
    images.count
  end
  
end
