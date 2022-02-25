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

  private

    def image_source_params
      params.require(:image_source).permit(:name, :active)
    end

end
