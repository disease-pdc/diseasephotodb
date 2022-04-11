class GradingSetsController < ApplicationController

  before_action :require_image_viewer, only: [:index]
  before_action :require_image_admin, only: [:create]

  def index
    wheres = ["1=1"]
    wheres_params = {}
    unless params[:text].blank?
      wheres << 'name ilike :name'
      wheres_params[:name] = "%#{params[:text]}%"
    end
    @grading_sets = GradingSet.order("name asc")
      .where(wheres.join(" and "), wheres_params)
    respond_to do |format|
      format.html
      format.json { render json: {grading_sets: @grading_sets} }
    end
  end

  def create

  end

end
