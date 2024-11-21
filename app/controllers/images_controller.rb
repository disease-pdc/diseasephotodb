class ImagesController < ApplicationController
  include CsvStreamable

  before_action :require_image_viewer, only: [:index, :show, :download]
  before_action :require_image_admin, only: [:create, :update, :destroy]
  before_action :require_admin, only: [:addtogradingset]

  skip_before_action :verify_authenticity_token, 
    only: [:addtogradingset, :metadata, :exif_data, :gradingdata]
  
  skip_forgery_protection only: [:index]

  def index
    @pagesize = 50
    @limit = (params[:limit] || @pagesize).to_i
    @offset = (params[:offset] || 0).to_i
    @images = Image.search(params).limit(@limit).offset(@offset)
    @images_count = Image.search(params).count
    @image_sources = ImageSource.active.order('name desc')
    @metadata_keys = Image.all_metadata_keys
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
    @image_sources = ImageSource.active.order("name desc").all
    @image_source_id = params[:image_source_id]
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
      @image_ids = Image.search(params).select(:id).map(&:id)
      @count = GradingSetImage.upsert_all(@image_ids.map {|image_id|
        {
          gradeable_id: image_id, 
          gradeable_type: 'Image', 
          grading_set_id: @grading_set.id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      }, unique_by: [:grading_set_id, :gradeable_id], returning: [:id]).count
    else
      @count = GradingSetImage.upsert_all(params[:image_ids].map {|image_id|
        {
          gradeable_id: image_id, 
          gradeable_type: 'Image', 
          grading_set_id: @grading_set.id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      }, unique_by: [:grading_set_id, :gradeable_id], returning: [:id]).count
    end
    return redirect_to({ action: 'index' }, flash: {
      success: "Successfully added #{@count} images to #{@grading_set.name}"
    })
  end

  def metadata
    stream_csv_response filename: 'metadata.csv',
      enumerator: Image.csv_metadata_enumerator(search_image_ids(params))
  end

  def exif_data
    stream_csv_response filename: 'exif_data.csv',
      enumerator: Image.csv_exif_data_enumerator(search_image_ids(params))
  end

  def download
    @image_sources = ImageSource.active.order("name desc").all
    @image_source_id = params[:image_source_id]
  end

  def gradingdata
    stream_csv_response filename: 'image_gradingdata.csv',
      enumerator: UserGradingSetImage.data_csv_enumerator({
        images: params
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

    def search_image_ids(params)
      Image.search(params).select(:id).map(&:id)
    end

end
