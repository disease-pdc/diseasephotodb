class ImageVariantJob
  include Sidekiq::Worker

  def perform id
    image = Image.find id
    Image::SIZES.each do |key,size|
      image.image_file.variant(resize_to_limit: size).processed
    end
  end

end
