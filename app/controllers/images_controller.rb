class ImagesController < ApplicationController

  before_action :require_image_viewer, only: [:index, :show]
  before_action :require_image_admin, only: [:create, :update, :destroy]

  def index
    @images = Image.active
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
        format.html { redirect_to @image, notice: 'Image was sucessfully uploaded.' }
        format.json { render json: @image }
      else
        format.html { render action: 'new' }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
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

end
