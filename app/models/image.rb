class Image < ApplicationRecord

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

end
