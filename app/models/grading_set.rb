require 'csv'

class GradingSet < ApplicationRecord

  DEFAULT_FLIPPED_PERCENT = 10

  FGS_GRADING_DATA_KEYS = [
    'name_of_expert_reviewer',
    'other_expert_reviewer',
    'pid',
    'cervical_images_assessed',
    'cervical_image_comments',
    'vaginal_wall_images_assessed',
    'image_comments',
    'grainy_sandy_patches',
    'location_grainy_sandy_patches',
    'homogeneous_yellow_patches',
    'location_homogeneous_yellow',
    'rubbery_papules',
    'location_rubbery_papules',
    'abnormal_blood_vessels',
    'location_abnormal_blood_vessel',
    'fgs_status',
    'suspected_sti',
    'other_reproductive_problem',
    'specify_reproductive_problem',
    'additional_comments'
  ]

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

  def data_to_csv
    headers = %w{filename source email grade}
    CSV.generate(headers: true) do |csv|
      csv << headers
    end
  end


  def csv_enumerator
    Enumerator.new do |yielder|
      headers_written = false
      UserGradingSetImage.joins(:grading_set_image, :user)
          .where("grading_set_images.grading_set_id = ?", id)
          .find_in_batches do |batch|
        batch.each do |user_grading_set_image|
          unless headers_written
            yielder << CSV.generate_line(
              %w(id filename source user_id) + FGS_GRADING_DATA_KEYS
            )
            headers_written = true
          end
          yielder << CSV.generate_line(
            [
              user_grading_set_image.id,
              user_grading_set_image.grading_set_image.gradeable.name,
              user_grading_set_image.grading_set_image.gradeable.image_source.name,
              user_grading_set_image.user.id
            ] + 
            FGS_GRADING_DATA_KEYS.map{|k| user_grading_set_image.grading_data[k]}
          )
        end
      end
    end
  end

end
