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
    ActiveRecord::Base.connection.execute(%(
      with grading_set_images_count as (
        select count(*) as count from grading_set_images where grading_set_id = #{id}
      ), complete_users as (
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

  def data_to_csv
    headers = %w{filename source email grade}
    CSV.generate(headers: true) do |csv|
      csv << headers
    end
  end

end
