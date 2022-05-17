class GradingSetsController < ApplicationController

  before_action :require_image_viewer, only: [:index, :show]
  before_action :require_image_admin, only: [:create, :adduser, :removeuser, :removeimage]

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

  def show
    @grading_set = GradingSet.find params[:id]
  end

  def new
    @grading_set = GradingSet.new
  end

  def edit
    @grading_set = GradingSet.find params[:id]
  end

  def update
    @grading_set = GradingSet.find params[:id]
    if @grading_set.update grading_set_params
      flash.notice = "Grading set #{@grading_set.name} updated"
      return redirect_to action: 'show'
    else
      return render action: 'show'
    end
  end

  def create
    @grading_set = GradingSet.new grading_set_params
    if @grading_set.save
      flash.notice = "Grading set #{@grading_set.name} created"
      return redirect_to action: 'index'
    else
      return render action: 'new'
    end
  end

  def data
    @grading_set = GradingSet.find params[:id]

    headers.delete("Content-Length")
    headers["Cache-Control"] = "no-cache"
    headers["Content-Type"] = "text/csv"
    headers["Content-Disposition"] = "attachment; filename=\"report.csv\""
    headers["X-Accel-Buffering"] = "no"

    response.status = 200

    self.response_body = @grading_set.csv_enumerator
  end

  def destroy

  end

  def adduser
    @grading_set = GradingSet.find params[:id]
    @user = User.find params[:user_id]
    if @user
      if UserGradingSet.upsert({
        user_id: @user.id,
        grading_set_id: @grading_set.id,
        created_at: Time.zone.now,
        updated_at: Time.zone.now
      }, unique_by: [:user_id, :grading_set_id])
        flash.notice = "#{@user.email} added to grading set"
      else
        flash.alert = "Unable to add #{@user.email} to grading set"
      end
    else
      flash.alert = "User #{@user.email} not found"
    end
    redirect_to action: 'show'
  end

  def removeuser
    @grading_set = GradingSet.find params[:id]
    @user = User.find params[:user_id]
    @user_grading_set = UserGradingSet.where({
      user: @user,
      grading_set: @grading_set
    }).first
    if @user_grading_set && @user_grading_set.destroy
      flash.notice = "#{@user.email} removed from grading set"
    else
      flash.alert = "Unable to remove #{@user.email} from grading set"
    end
    redirect_to action: 'show'
  end

  def removeimage
    @grading_set = GradingSet.find params[:id]
    @image = Image.find params[:image_id]
    @grading_set_image = GradingSetImage.where({
      image: @image,
      grading_set: @grading_set
    }).first
    if @grading_set_image && @grading_set_image.destroy
      flash.notice = "#{@image.filename} removed from grading set"
    else
      flash.alert = "Unable to remove #{@image.filename} from grading set"
    end
    redirect_to action: 'show'
  end

  private

    def grading_set_params
      params.require(:grading_set).permit(:name)
    end

end
