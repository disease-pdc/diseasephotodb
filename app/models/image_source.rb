class ImageSource < ApplicationRecord

  has_many :images

  scope :active, -> { where(active: true) }

  validates 'name', presence: true, uniqueness: true

  def image_count
    images.count
  end
  
end
