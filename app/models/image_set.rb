class ImageSet < ApplicationRecord
  include JsonKeyable, MetadataManagable, ImageVariantable

  FIXED_METADATA = %w(id name source)

  belongs_to :image_source

  has_many :image_set_images
  has_many :images, -> { order('images.filename') },
    through: :image_set_images
  has_many :grading_set_images, as: :gradeable
  has_many :grading_sets, through: :grading_set_images

  has_many :image_set_images, dependent: :delete_all

  scope :active, -> { joins(:image_source).where('image_sources.active', true) }

  validates 'image_source_id', presence: true
  validates 'source_metadata_name', presence: true
  validates 'name', presence: true
  validates 'metadata', presence: true,  allow_blank: false

  def self.all_metadata_keys
    ImageSet.query_json_metadata_keys 'metadata'
  end

  def self.csv_metadata_enumerator ids
    keys = ImageSet.all_metadata_keys - FIXED_METADATA
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(FIXED_METADATA + keys)
      ImageSet.where('id in (?)', ids)
          .includes(:image_source)
          .find_each do |image_set|
        data = [image_set.id, image_set.name, image_set.image_source.name]
        keys.each { |k| data << image_set.metadata[k] }
        yielder << CSV.generate_line(data)
      end
    end
  end

  def self.apply_to_image_set image
    if image.image_source.create_image_sets?
      metadata_field = image.image_source.create_image_sets_metadata_field
      metadata_value = image.metadata[metadata_field]
      unless metadata_value.blank?
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
  end

  def self.search params
    wheres = ["1=1"]
    wheres_params = {}
    joins = []
    unless params[:metadata_key].blank?
      safe_key = params[:metadata_key].gsub("'", "") # remove single quotes
      wheres << "image_sets.metadata->>'#{safe_key}' like :metadata_value"
      if !(params[:metadata_value].blank?)
        wheres_params[:metadata_value] = "%#{params[:metadata_value]}%"
      elsif !(params[:metadata_value_eq].blank?)
        wheres_params[:metadata_value] = "#{params[:metadata_value_eq]}"
      end
    end
    unless params[:image_set_ids].blank?
      wheres << 'image_sets.id in (:image_set_ids)'
      wheres_params[:image_set_ids] = params[:image_set_ids]
    end
    unless params[:name].blank?
      wheres << 'image_sets.name ilike :name'
      wheres_params[:name] = "%#{params[:name]}%"
    end
    unless params[:image_source_id].blank?
      wheres << 'image_sets.image_source_id = :image_source_id'
      wheres_params[:image_source_id] = params[:image_source_id]
    end
    unless params[:image_source].blank?
      joins << :image_source
      wheres << 'image_sources.name ilike :image_source'
      wheres_params[:image_source] = "%#{params[:image_source]}%"
    end
    unless params[:grading_set].blank?
      joins << :grading_sets
      wheres << 'grading_sets.name ilike :grading_set'
      wheres_params[:grading_set] = "%#{params[:grading_set]}%"
    end
    ImageSet.active.joins(joins)
      .order("image_sets.name asc")
      .where(wheres.join(" and "), wheres_params)
  end

  def variant_url variant
    images.first&.variant_url(variant) || ImageVariantable::PROCESSING_URL
  end

  def fixed_metadata
    FIXED_METADATA
  end

  def image_count
    image_set_images.count
  end

end
