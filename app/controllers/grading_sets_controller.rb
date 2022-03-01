class GradingSetsController < ApplicationController

  before_action :require_image_viewer, only: [:index]

  def index
    @grading_sets = GradingSet.all
  end

end
