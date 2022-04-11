require 'csv'

class GradingSet < ApplicationRecord

  has_many :grading_set_images
  has_many :images, through: :grading_set_images
  has_many :user_grading_sets
  has_many :users, through: :user_grading_sets

  def image_count
    images.count
  end

  def user_grading_sets_complete_count
    0
  end

  def data_to_csv
    headers = %w{filename source email grade}
    CSV.generate(headers: true) do |csv|
      csv << headers
    end
  end

end
