module ApplicationHelper

  def grading_set_link grading_set
    if current_user.admin?
      link_to grading_set.name, controller: 'grading_sets', action: 'show', id: grading_set.id
    else
      grading_set.name
    end
  end

  def gradeable_url gradeable
    if gradeable.class == Image
       url_for controller: 'images', action: 'show', id: gradeable.id
    elsif gradeable.class == ImageSet
       url_for controller: 'image_sets', action: 'show', id: gradeable.id
    end
  end

end
