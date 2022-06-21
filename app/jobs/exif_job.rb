require 'open-uri'
require 'exifr/jpeg'
require 'exifr/tiff'

class ExifJob
  include Sidekiq::Worker

  def perform id
    image = Image.find id
    if image.filename =~ /.jp/i
      image.exif_data = EXIFR::JPEG.new(get_image(image)).to_hash
      image.save!
    elsif image.filename =~ /.tif/i
      image.exif_data = EXIFR::TIFF.new(get_image(image)).to_hash
      image.save!
    end
  end

  private

    def get_image image
      if ActiveStorage::Blob.service.name == :local
        open(ActiveStorage::Blob.service.path_for image.image_file.key)
      else
        URI.open(image.image_file.url)
      end
    end

end
