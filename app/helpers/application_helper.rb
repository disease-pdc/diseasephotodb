module ApplicationHelper

  def grading_set_link grading_set
    if current_user.admin?
      link_to grading_set.name, controller: 'grading_sets', action: 'show', id: grading_set.id
    else
      grading_set.name
    end
  end

end
