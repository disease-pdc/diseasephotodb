require "active_support/concern"

module ImageVariantable
  extend ActiveSupport::Concern

  PROCESSING_URL = '/processing.png'
  SIZES = {
    main: [1000,1000],
    preview: [300,300],
    list: [150,150]
  }

  def variant_url variant
    if (image_file.variant(resize_to_limit: variant).processed?)
      if ActiveStorage::Blob.service.name == :local
        Rails.application.routes.url_helpers.rails_representation_url(
          image_file.variant(resize_to_limit: variant), only_path: true
        )
      else
        image_file.variant(resize_to_limit: variant).processed.url
      end
    else
      ImageVariantable::PROCESSING_URL
    end
  end

  def image_url_list
    variant_url SIZES[:list]
  end

  def image_url_preview
    variant_url SIZES[:preview]
  end

  def image_url_main
    variant_url SIZES[:main]
  end

end