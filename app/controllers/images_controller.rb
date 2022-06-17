class ImagesController < ApplicationController

  before_action :require_image_viewer, only: [:index, :show]
  before_action :require_image_admin, only: [:create, :update, :destroy]

  skip_before_action :verify_authenticity_token, only: [:addtogradingset]
  
  skip_forgery_protection only: [:index]

  def index
    @pagesize = 50
    @limit = (params[:limit] || @pagesize).to_i
    @offset = (params[:offset] || 0).to_i
    @images = search_images.limit(@limit).offset(@offset)
    @images_count = search_images.count
    respond_to do |format|
      format.html 
      format.json { render json: {images: @images} }
    end
  end

  def show
    @image = Image.find params[:id]
    respond_to do |format|
      format.html 
      format.json { render json: @image }
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new new_image_params
    @image.user = current_user
    if params[:image][:image_file]
      @image.filename = params[:image][:image_file].original_filename
      @image.mime_type = params[:image][:image_file].content_type
    end
    respond_to do |format|
      if @image.save
        ExifJob.perform_async @image.id
        format.html { redirect_to @image, notice: 'Image was sucessfully uploaded.' }
        format.json { render json: {success: true, image: @image, filename: @image.filename}}
      else
        format.html { render action: 'new' }
        format.json { render json: {errors: @image.errors.full_messages, filename: params[:image][:image_file].original_filename} }
      end
    end
  end

  def addtogradingset
    @grading_set = GradingSet.find params[:grading_set_id]
    unless @grading_set
      return redirect_to({ action: 'index' }, flash: { error: "No such grading set" })
    end
    if params[:image_id_all] == 'all'
      @image_ids = search_images.select(:id).map(&:id)
      @count = GradingSetImage.upsert_all(@image_ids.map {|image_id|
        {
          image_id: image_id, 
          grading_set_id: @grading_set.id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      }, unique_by: [:grading_set_id, :image_id], returning: [:id]).count
    else
      @count = GradingSetImage.upsert_all(params[:image_ids].map {|image_id|
        {
          image_id: image_id, 
          grading_set_id: @grading_set.id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      }, unique_by: [:grading_set_id, :image_id], returning: [:id]).count
    end
    return redirect_to({ action: 'index' }, flash: {
      success: "Successfully added #{@count} images to #{@grading_set.name}"
    })
  end

  # def update
  #   @image = Image.find params[:id]
  #   respond_to do |format|
  #     if @image.update image_params

  #     else
  #       format.html { render :show }
  #       format.json { render json: @image.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  private

    def new_image_params
      params.require(:image).permit(
        :metadata,
        :image_source_id,
        :image_file
      )
    end

    def search_images
      wheres = ["1=1"]
      wheres_params = {}
      joins = []
      unless params[:filename].blank?
        wheres << 'filename ilike :filename'
        wheres_params[:filename] = "%#{params[:filename]}%"
      end
      unless params[:image_source].blank?
        joins << :image_source
        wheres << 'image_sources.name ilike :image_source'
        wheres_params[:image_source] = "%#{params[:image_source]}%"
      end
      unless params[:grading_set].blank?
        joins << :grading_sets
        wheres << 'grading_sets.name ilike :grading_set'
        wheres_params[:grading_set] = "%#{params[:grading_set]}%"
      end
      Image.active.joins(joins)
        .order("images.filename asc")
        .where(wheres.join(" and "), wheres_params)
    end

end
