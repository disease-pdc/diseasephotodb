class ImageSource < ApplicationRecord

  validates 'name', presence: true, uniqueness: true

  def image_count
    0
  end
  
end
