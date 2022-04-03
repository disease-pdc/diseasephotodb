class ImageSourcesController < ApplicationController

  before_action :require_image_admin

  def index
    @image_sources = ImageSource.all.order("name asc")
  end

  def show
    @image_source = ImageSource.find params[:id]
  end

  def new
    @image_source = ImageSource.new
  end

  def update
    @image_source = ImageSource.find params[:id]
    if @image_source.update image_source_params
      flash.notice = "Image source updated"
      return redirect_to action: 'index'
    else
      return render action: 'show'
    end
  end

  def create
    @image_source = ImageSource.new image_source_params
    if @image_source.save
      flash.notice = "Image source created"
      return redirect_to action: 'index'
    else
      return render action: 'new'
    end
  end

  def destroy
    @image_source = ImageSource.find params[:id]
    if @image_source.destroy
      flash.notice = "Image source deleted"
      return redirect_to action: 'index'
    else
      return render action: 'show'
    end
  end

  def metadata
    @image = Image.where(
      image_source_id: params[:id],
      filename: params[:filename]
    ).first
    unless @image
      render json: {error: 'Image not found'}, staus: :unprocessable_entity
    else
      @image.metadata = params[:metadata]
      if @image.save
        render json: {success: true}
      else
        render json: {error: @image.errors}, staus: :unprocessable_entity 
      end
    end
  end

  private

    def image_source_params
      params.require(:image_source).permit(:name, :active)
    end

    def metadata_params
      params.require(:filename, metadata: [])
    end

end
