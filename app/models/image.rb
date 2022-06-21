class Image < ApplicationRecord

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
