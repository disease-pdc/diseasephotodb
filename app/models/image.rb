class Image < ApplicationRecord

  belongs_to :image_source

  validates 'filename', 
    presence: true,
    uniqueness: { scope: [:image_source_id] }
  validates 'image_source_id', 
    presence: true, 
    message: 'Image source is required'
  validates 'mime_type', presence: true
  validates 'metadata', presence: true
  validates 'exif_data', presence: true


end
