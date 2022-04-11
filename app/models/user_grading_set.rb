class UserGradingSet < ApplicationRecord

  after_destroy :destroy_user_grading_set_images

  belongs_to :user
  belongs_to :grading_set

  def user_grading_set_images
    user.user_grading_set_images
      .joins(:grading_set_image)
      .where('grading_set_images.grading_set_id = ?', grading_set.id)
  end

  def next_grading_set_image
    grading_set_image = GradingSetImage
      .where('grading_set_id = ?', grading_set_id)
      .where(%(
        grading_set_images.id not in (
          select grading_set_image_id 
          from user_grading_set_images 
            join grading_set_images on grading_set_image_id = grading_set_images.id
          where grading_set_images.grading_set_id = ? and user_id = ?
        )
      ), grading_set_id, user_id)
      .order('grading_set_images.id asc')
      .first
    unless grading_set_image
      grading_set_image = GradingSetImage
        .where('grading_set_id = ?', grading_set_id)
        .where(%(
          grading_set_images.id in (
            select grading_set_image_id 
            from user_grading_set_images 
              join grading_set_images on grading_set_image_id = grading_set_images.id
            where grading_set_images.grading_set_id = ? and user_id = ?
          )
        ), grading_set_id, user_id)
        .order('grading_set_images.id desc')
        .first
    end
    return grading_set_image
  end

  def complete_image_count
    user_grading_set_images.count
  end

  def image_count
    grading_set.image_count
  end

  def complete?

  end

  def index_of_image image
    user_grading_set_images
      .joins(:grading_set_image)
      .where('grading_set_images.image_id < ?', image.id)
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
