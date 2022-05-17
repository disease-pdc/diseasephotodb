class UserGradingSetImage < ApplicationRecord

  YES_NO_VALUES = {
    yes: 'y',
    no: 'n'
  }

  GRADE_VALUES = {
    positive: 'p',
    negative: 'n',
    maybe_positive: 'mp',
    maybe_negative: 'mn'
  }

  belongs_to :user
  belongs_to :grading_set_image

  def grade_text
    TEXT_VALUES[grade] || 'Unknown grade value'
  end

end
