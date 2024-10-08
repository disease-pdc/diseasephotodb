class Image < ApplicationRecord
  include JsonKeyable

  PROCESSING_URL = '/processing.png'
  SIZES = {
    main: [1000,1000],
    list: [150,150]
  }

  has_one_attached :image_file
  belongs_to :image_source
  belongs_to :user
  has_many :grading_set_images
  has_many :grading_sets, through: :grading_set_images

  scope :active, -> { joins(:image_source).where('image_sources.active', true) }

  validates 'image_file', presence: true
  validates 'image_source_id', presence: true
  validates 'filename', presence: true,
    uniqueness: { scope: [:image_source_id] }
  validates 'mime_type', presence: true

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

  def do_image_processing
    ExifJob.perform_async self.id
    ImageVariantJob.perform_async self.id
  end

  def variant_url variant
    if (image_file.variant(resize_to_limit: variant).processed?)
      if ActiveStorage::Blob.service.name == :local
        image_file.variant(resize_to_limit: variant)
      else
        image_file.variant(resize_to_limit: variant).processed.url
      end
    else
      PROCESSING_URL
    end
  end

end
