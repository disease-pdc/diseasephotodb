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

  def csv_enumerator
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(%w(
        id filename source user_id photo_quality is_everted tf_grade ti_grade 
        ts_grade upper_lid_tt_grade lower_lid_tt_grade
      ))
      UserGradingSetImage.joins({grading_set_image: :image}, :user)
          .where("grading_set_images.grading_set_id = ?", id)
          .find_in_batches do |batch|
        batch.each do |user_grading_set_image|
          yielder << CSV.generate_line([
            user_grading_set_image.id,
            user_grading_set_image.grading_set_image.image.filename,
            user_grading_set_image.grading_set_image.image.image_source.name,
            user_grading_set_image.user.id,
            user_grading_set_image.grading_data['photo_quality'],
            user_grading_set_image.grading_data['is_everted'],
            user_grading_set_image.grading_data['tf_grade'],
            user_grading_set_image.grading_data['ti_grade'],
            user_grading_set_image.grading_data['ts_grade'],
            user_grading_set_image.grading_data['upper_lid_tt_grade'],
            user_grading_set_image.grading_data['lower_lid_tt_grade']
          ])
        end
      end
    end
  end

end
