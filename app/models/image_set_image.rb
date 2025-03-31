class ImageSetImage < ApplicationRecord

  belongs_to :image
  belongs_to :image_set

  def destroy_and_image!
    image.destroy!
    self.destroy!
  end

end
