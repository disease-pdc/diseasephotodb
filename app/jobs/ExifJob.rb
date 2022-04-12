require 'open-uri'
require 'exifr/jpeg'
require 'exifr/tiff'

class ExifJob
  include Sidekiq::Worker

  def perform id
    image = Image.find id
    if image.filename =~ /.jp/i
      image.exif_data = EXIFR::JPEG.new(open(get_image_url(image))).to_hash
      image.save!
    elsif image.filename =~ /.tif/i
      image.exif_data = EXIFR::TIFF.new(open(get_image_url(image))).to_hash
      image.save!
    end
  end

  private

    def get_image_url image
      if ActiveStorage::Blob.service.name == :local
        ActiveStorage::Blob.service.path_for image.image_file.key
      else
        image.image_file.url
      end
    end

end
