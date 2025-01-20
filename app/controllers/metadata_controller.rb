class MetadataController < ApplicationController

  before_action :require_image_admin

  def index
    @image_sources = ImageSource.active.order("name desc").all
    @image_source_id = params[:image_source_id]
  end

  def update
    if params[:type] == 'image_set'
      @entity = image_set_by_params
      entity_name = @entity&.name
    else
      @entity = image_by_params
      entity_name = @entity&.filename
    end
    unless @entity
      render json: {filename: entity_name, error: "#{params[:type] == 'image_set' ? 'Image Set' : 'Image'} not found"}, staus: :unprocessable_entity
    else
      if @entity.update_metadata metadata_params[:metadata], params[:merge_metadata]
        render json: {filename: entity_name, success: true}
      else
        render jsons: {filename: entity_name, error: @entity.errors}, staus: :unprocessable_entity 
      end
    end
  end

  private

    def image_by_params
      if params[:id]
        Image.find(params[:id])
      else
        Image.where(
          image_source_id: params[:image_source_id],
          filename: params[:filename] || params[:name]
        ).first
      end
    end

    def image_set_by_params
      if params[:id]
        ImageSet.find(params[:id])
      else
        ImageSet.where(
          image_source_id: params[:image_source_id],
          name: params[:filename] || params[:name]
        ).first
      end
    end

    def metadata_params
      params.permit(metadata: {})
    end
end
