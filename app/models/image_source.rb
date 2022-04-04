class ImageSource < ApplicationRecord

  has_many :images

  default_scope { where(active: true) }

  validates 'name', presence: true, uniqueness: true

  def image_count
    images.count
  end
  
end
