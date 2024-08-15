class Image < ApplicationRecord
  include JsonKeyable, MetadataManagable, ImageVariantable

  PROCESSING_URL = '/processing.png'
  SIZES = {
    main: [1000,1000],
    preview: [300,300],
    list: [150,150]
  }

  has_one_attached :image_file
  belongs_to :image_source
  belongs_to :user
  has_many :grading_set_images, as: :gradeable
  has_many :grading_sets, through: :grading_set_images
  has_many :image_set_images
  has_many :image_sets, through: :image_set_images

  scope :active, -> { joins(:image_source).where('image_sources.active', true) }

  validates 'image_file', presence: true
  validates 'image_source_id', presence: true
  validates 'filename', presence: true,
    uniqueness: { scope: [:image_source_id] }
  validates 'mime_type', presence: true

  after_save :do_image_set_association
  after_commit :do_image_processing, on: [:create]

  def self.all_metadata_keys
    Image.query_json_metadata_keys 'metadata'
  end

  def self.all_exif_data_keys
    Image.query_json_metadata_keys 'exif_data'
  end

  def self.csv_metadata_enumerator ids
    keys = Image.all_metadata_keys
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(%w(id filename source mime_type) + keys)
      Image.where('id in (?)', ids)
          .includes(:image_source)
          .find_each do |image|
        data = [image.id, image.filename, image.image_source.name, image.mime_type]
        keys.each { |k| data << image.metadata[k] }
        yielder << CSV.generate_line(data)
      end
    end
  end

  def self.csv_exif_data_enumerator ids
    keys = Image.all_exif_data_keys
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(%w(id filename source mime_type) + keys)
      Image.where('id in (?)', ids)
          .includes(:image_source)
          .find_each do |image|
        data = [image.id, image.filename, image.image_source.name, image.mime_type]
        keys.each { |k| data << image.exif_data[k] }
        yielder << CSV.generate_line(data)
      end
    end
  end

  def name
    filename
  end

  def do_image_processing
    ExifJob.perform_async self.id
    ImageVariantJob.perform_async self.id
  end

  def do_image_set_association
    if saved_change_to_attribute?(:metadata) && image_source.create_image_sets?
      ImageSet.apply_to_image_set self
    end
  end

end
