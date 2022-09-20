class UserGradingSet < ApplicationRecord

  after_destroy :destroy_user_grading_set_images

  belongs_to :user
  belongs_to :grading_set

  def user_grading_set_images
    user.user_grading_set_images
      .joins(:grading_set_image)
      .where('flipped = false')
      .where('grading_set_images.grading_set_id = ?', grading_set.id)
  end

  def user_grading_set_images_flipped
    user.user_grading_set_images
      .joins(:grading_set_image)
      .where('flipped = true')
      .where('grading_set_images.grading_set_id = ?', grading_set.id)
  end

  def next_grading_set_image
    return GradingSetImage
      .where('grading_set_id = ?', grading_set_id)
      .where(%(
        grading_set_images.id not in (
          select grading_set_image_id 
          from user_grading_set_images 
            join grading_set_images on grading_set_image_id = grading_set_images.id
          where grading_set_images.grading_set_id = ? 
            and user_id = ?
            and user_grading_set_images.flipped = false
        )
      ), grading_set_id, user_id)
      .order('grading_set_images.id asc')
      .first
    # unless grading_set_image
    #   grading_set_image = GradingSetImage
    #     .where('grading_set_id = ?', grading_set_id)
    #     .where(%(
    #       grading_set_images.id in (
    #         select grading_set_image_id 
    #         from user_grading_set_images 
    #           join grading_set_images on grading_set_image_id = grading_set_images.id
    #         where grading_set_images.grading_set_id = ? 
    #           and user_id = ?
    #           and user_grading_set_images.flipped = false
    #       )
    #     ), grading_set_id, user_id)
    #     .order('grading_set_images.id desc')
    #     .first
    # end
    # return grading_set_image
  end

  def next_grading_set_image_flipped
    return GradingSetImage
      .where('grading_set_id = ?', grading_set_id)
      .where(%(
        grading_set_images.id in (
          select grading_set_image_id 
          from user_grading_set_images 
            join grading_set_images on grading_set_image_id = grading_set_images.id
          where grading_set_images.grading_set_id = ? 
            and user_id = ?
            and flipped = false
        )
      ), grading_set_id, user_id)
      .where(%(
        grading_set_images.id not in (
          select grading_set_image_id 
          from user_grading_set_images 
            join grading_set_images on grading_set_image_id = grading_set_images.id
          where grading_set_images.grading_set_id = ? 
            and user_id = ?
            and flipped = true
        )
      ), grading_set_id, user_id)
      .order('random()')
      .first
  end

  def complete_image_count
    user_grading_set_images.count
  end

  def complete_image_count_flipped
    user_grading_set_images_flipped.count
  end

  def complete_image_count_total
    complete_image_count + complete_image_count_flipped
  end

  def image_count
    grading_set.image_count
  end

  def flipped_image_count
    grading_set.flipped_image_count
  end

  def total_image_count
    grading_set.total_image_count
  end

  def image_complete?
    complete_image_count >= image_count
  end

  def image_flipped_complete?
    complete_image_count_flipped >= flipped_image_count
  end

  def complete?
    complete_image_count_total >= total_image_count
  end

  def index_of_grading_set_image grading_set_image
    user_grading_set_images
      .joins(:grading_set_image)
      .where('grading_set_images.id < ?', grading_set_image.id)
      .count
  end

  def user_grading_set_image_for image
    user_grading_set_images
      .joins(:grading_set_image)
      .where('grading_set_images.image_id = ?', image.id)
      .first
  end

  def destroy_user_grading_set_images
    user_grading_set_images.delete_all
  end

end
