require 'csv'

class GradingSet < ApplicationRecord

  DEFAULT_FLIPPED_PERCENT = 0

  has_many :grading_set_images
  has_many :user_grading_sets
  has_many :users, through: :user_grading_sets

  validates :name, presence: true, allow_blank: false, uniqueness: true
  validates :flipped_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, presence: true, allow_blank: false
  
  # Number of associated image with this grading set
  def image_count
    grading_set_images.count
  end

  # Number of images to test flipped with this grading set
  def flipped_image_count
    (grading_set_images.count * (flipped_percent / 100.0)).ceil
  end

  # Total number of images (including flipped) that will be tested on this set
  def total_image_count
    image_count + flipped_image_count
  end

  # Returns the number of complete user grading sets:
  # Calculated as complete = # of images + # of images * flipped_percent
  def user_grading_sets_complete_count
    ActiveRecord::Base.connection.execute(%(
      with grading_set_images_count as (
        select count(*) + (count(*) * ceil(max(flipped_percent) / 100.0)) as count 
          from grading_set_images
            join grading_sets on grading_sets.id = grading_set_images.grading_set_id
          where grading_set_id = #{id}
      ), 
      complete_users as (
        select user_grading_set_images.user_id as id, count(user_grading_set_images.id) as count
        from user_grading_set_images
        join grading_set_images on grading_set_images.id = user_grading_set_images.grading_set_image_id
        where grading_set_images.grading_set_id = #{id}
        group by user_grading_set_images.user_id
      )
      select count(complete_users.id) as count
      from complete_users, grading_set_images_count
      where complete_users.count = grading_set_images_count.count
    )).first['count']
  end

end
