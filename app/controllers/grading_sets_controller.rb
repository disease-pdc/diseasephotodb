class GradingSetsController < ApplicationController

  before_action :require_image_viewer, only: [:index]
  before_action :require_image_admin, only: [:create]

  def index
    @grading_sets = GradingSet.all
  end

  def create

  end

end
