class UserGradingSetImage < ApplicationRecord

  TEXT_VALUES = {
    1 => 'Positive',
    2 => 'Mostly Positive',
    3 => 'Mostly Negative',
    4 => 'Negative'
  }

  belongs_to :user
  belongs_to :grading_set_image

  def grade_text
    TEXT_VALUES[grade] || 'Unknown grade value'
  end

end
