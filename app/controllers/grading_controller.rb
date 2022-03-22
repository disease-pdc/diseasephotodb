class GradingController < ApplicationController

  def index
    @user_grading_set = current_user.user_grading_set_for(params[:grading_set_id])
    @grading_set_image = @user_grading_set.next_grading_set_image
    if @grading_set_image
      @user_grading_set_image = @user_grading_set.user_grading_set_image_for @grading_set_image.image
    end
  end

  def show
    @user_grading_set = current_user.user_grading_set_for(params[:grading_set_id])
    @user_grading_set_image = UserGradingSetImage.where(
      user_id: current_user.id,
      id: params[:user_grading_set_image_id]
    ).first
    @grading_set_image = @user_grading_set_image.grading_set_image
    render 'index'
  end

  def grade
    @user_grading_set = current_user.user_grading_set_for(params[:grading_set_id])
    @user_grading_set_image = UserGradingSetImage.where(
      user_id: current_user.id,
      grading_set_image: params[:grading_set_image_id]
    ).first
    unless @user_grading_set_image
      @user_grading_set_image = UserGradingSetImage.new(
        user: current_user,
        grading_set_image: GradingSetImage.find(params[:grading_set_image_id])
      )
    end
    @user_grading_set_image.grade = params[:grade]
    @user_grading_set_image.save!
    redirect_to action: 'show', 
      grading_set_id: params[:grading_set_id],
      user_grading_set_image_id: @user_grading_set_image.id
  end

  def complete
    @user_grading_set = current_user.user_grading_set_for(params[:grading_set_id])
    flash.notice = "#{@user_grading_set.grading_set.name} completed!"
    redirect_to controller: 'dashboard'
  end

end
