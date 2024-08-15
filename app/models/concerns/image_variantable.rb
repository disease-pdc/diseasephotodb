require "active_support/concern"

module ImageVariantable
  extend ActiveSupport::Concern

  PROCESSING_URL = '/processing.png'
  SIZES = {
    main: [1000,1000],
    list: [150,150]
  }

  def variant_url variant
    if (image_file.variant(resize_to_limit: variant).processed?)
      if ActiveStorage::Blob.service.name == :local
        image_file.variant(resize_to_limit: variant)
      else
        image_file.variant(resize_to_limit: variant).processed.url
      end
    else
      ImageVariantable::PROCESSING_URL
    end
  end

  def image_url_list
    Rails.application.routes.url_helpers.rails_representation_url(self.variant_url(ImageVariantable::SIZES[:list]), only_path: true)
  end

  def image_url_main
    Rails.application.routes.url_helpers.rails_representation_url(self.variant_url(ImageVariantable::SIZES[:main]), only_path: true)
  end

end