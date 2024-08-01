class ImageSet < ApplicationRecord
  include JsonKeyable, MetadataManagable

  belongs_to :image_source

  has_many :image_set_images
  has_many :images, -> { order('images.filename') },
    through: :image_set_images

  scope :active, -> { joins(:image_source).where('image_sources.active', true) }

  validates 'image_source_id', presence: true
  validates 'source_metadata_name', presence: true
  validates 'name', presence: true
  validates 'metadata', presence: true,  allow_blank: false

  def self.all_metadata_keys
    ImageSet.query_json_metadata_keys 'metadata'
  end

  def self.apply_to_image_set image
    if image.image_source.create_image_sets?
      metadata_field = image.image_source.create_image_sets_metadata_field
      metadata_value = image.metadata[metadata_field]
      image_set = ImageSet.upsert({
        image_source_id: image.image_source.id,
        name: metadata_value,
        source_metadata_name: metadata_value,
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }, unique_by: [:image_source_id, :source_metadata_name])
      ImageSetImage.upsert({
        image_id: image.id,
        image_set_id: image_set.first['id'],
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }, unique_by: [:image_set_id, :image_id])
    end
  end

  def image_variant_url variant
    images.first&.variant_url(variant) || Image::PROCESSING_URL
  end

end
