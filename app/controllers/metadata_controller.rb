class MetadataController < ApplicationController

  before_action :require_image_admin

  def index
    @image_sources = ImageSource.active.order("name desc").all
    @image_source_id = params[:image_source_id]
  end

  def update
    @image = Image.where(
      image_source_id: params[:image_source_id],
      filename: params[:filename]
    ).first
    unless @image
      render json: {filename: params[:filename], error: 'Image not found'}, staus: :unprocessable_entity
    else
      if params[:merge_metadata]
        @image.metadata = (@image.metadata || {}).merge(metadata_params[:metadata])
      else
        @image.metadata = metadata_params[:metadata]
      end
      if @image.save
        render json: {filename: params[:filename], success: true}
      else
        render json: {filename: params[:filename], error: @image.errors}, staus: :unprocessable_entity 
      end
    end
  end

  private

    def metadata_params
      params.permit(metadata: {})
    end
end
