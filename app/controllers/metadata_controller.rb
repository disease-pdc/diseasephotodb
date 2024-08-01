class MetadataController < ApplicationController

  before_action :require_image_admin

  def index
    @image_sources = ImageSource.active.order("name desc").all
    @image_source_id = params[:image_source_id]
  end

  def update
    @entity = Image.where(
      image_source_id: params[:image_source_id],
      filename: params[:filename]
    ).first || ImageSet.where(
      image_source_id: params[:image_source_id],
      name: params[:filename]
    ).first
    unless @entity
      render json: {filename: params[:filename], error: 'Image or image set not found'}, staus: :unprocessable_entity
    else
      if @entity.update_metadata metadata_params[:metadata], params[:merge_metadata]
        render json: {filename: params[:filename], success: true}
      else
        render json: {filename: params[:filename], error: @entity.errors}, staus: :unprocessable_entity 
      end
    end
  end

  private

    def metadata_params
      params.permit(metadata: {})
    end
end
