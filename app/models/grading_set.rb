require 'csv'

class GradingSet < ApplicationRecord

  DEFAULT_FLIPPED_PERCENT = 0

  FGS_GRADING_MULTIDATA_OPTIONS = {
    location: %w(left_lateral_fornix right_lateral_fornix anterior_fornix posterior_fornix cervix_q1 cervix_q2 cervix_q3 cervix_q4 vaginal_walls),
    sti: %w(suspected_bacterial_vaginosis suspected_trichomonas candidiasis suspected_gonorrhoea suspected_chlamydia suspected_herpes genital_warts chancroid),
    repro: %w(buboes lymphogranuloma scabies crabs polyp ectropion nabothian_cyst prolapsed_uterus other_please_list),
    sti_repro: %w(1 2 3 4 5 6 7 8 9 10 11 12 13 14 95)
  }
  FGS_GRADING_DATA_KEYS = [
    {key: 'cervical_images_assessed'},
    {key: 'cervical_image_comments'},
    {key: 'vaginal_wall_images_assessed'},
    {key: 'image_comments'},
    {key: 'grainy_sandy_patches'},
    {key: 'location_grainy_sandy_patches', multi_options: FGS_GRADING_MULTIDATA_OPTIONS[:location]},
    {key: 'homogeneous_yellow_patches'},
    {key: 'location_homogeneous_yellow', multi_options: FGS_GRADING_MULTIDATA_OPTIONS[:location]},
    {key: 'rubbery_papules'},
    {key: 'location_rubbery_papules', multi_options: FGS_GRADING_MULTIDATA_OPTIONS[:location]},
    {key: 'abnormal_blood_vessels'},
    {key: 'location_abnormal_blood_vessel', multi_options: FGS_GRADING_MULTIDATA_OPTIONS[:location]},
    {key: 'fgs_status'},
    {key: 'sus_sti_repro'},
    {key: 'sti_repro_list', multi_options: FGS_GRADING_MULTIDATA_OPTIONS[:sti_repro]},
    {key: 'repro_other_desc'},
    {key: 'additional_comments'}
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

  # def csv_headers
  #   headers = %w(id grading_set name source user_id user_email)
  #   FGS_GRADING_DATA_KEYS.each do |key| 
  #     if key[:multi_options]
  #       key[:multi_options].each do |option|
  #         headers << "#{key[:key]}.#{option}"
  #       end
  #     else
  #       headers << key[:key]
  #     end
  #   end
  #   return headers
  # end

  # def csv_line_for user_grading_set_image
  #   line = [
  #     user_grading_set_image.id,
  #     self.name,
  #     user_grading_set_image.grading_set_image.gradeable.name,
  #     user_grading_set_image.grading_set_image.gradeable.image_source.name,
  #     user_grading_set_image.user.id,
  #     user_grading_set_image.user.email
  #   ]
  #   FGS_GRADING_DATA_KEYS.each do |key| 
  #     if key[:multi_options]
  #       key[:multi_options].each do |option|
  #         if user_grading_set_image.grading_data[key[:key]]&.include?(option)
  #           line << "1"
  #         else
  #           line << ""
  #         end
  #       end
  #     else
  #       line << user_grading_set_image.grading_data[key[:key]]
  #     end
  #   end
  #   return line
  # end

  # def csv_enumerator
  #   Enumerator.new do |yielder|
  #     headers_written = false
  #     UserGradingSetImage.search({grading_sets: {id: self.id}})
  #         .find_in_batches do |batch|
  #       batch.each do |user_grading_set_image|
  #         unless headers_written
  #           yielder << CSV.generate_line(self.csv_headers)
  #           headers_written = true
  #         end
  #         yielder << CSV.generate_line(csv_line_for(user_grading_set_image))
  #       end
  #     end
  #   end
  # end

end
