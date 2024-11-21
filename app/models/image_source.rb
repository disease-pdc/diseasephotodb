class ImageSource < ApplicationRecord

  has_many :images
  has_many :image_sets

  scope :active, -> { where(active: true) }

  validates 'name', presence: true,  allow_blank: false, uniqueness: true

  def image_count
    images.count
  end
  
end
