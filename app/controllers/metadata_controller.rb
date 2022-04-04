class MetadataController < ApplicationController

  before_action :require_image_admin

  def index
  end

  def update
    @image = Image.where(
      image_source_id: params[:image_source_id],
      filename: params[:filename]
    ).first
    unless @image
      render json: {filename: params[:filename], error: 'Image not found'}, staus: :unprocessable_entity
    else
      @image.metadata = params[:metadata]
      if @image.save
        render json: {filename: params[:filename], success: true}
      else
        render json: {filename: params[:filename], error: @image.errors}, staus: :unprocessable_entity 
      end
    end
  end

  private

    def metadata_params
      params.require(:filename, metadata: [])
    end

end
