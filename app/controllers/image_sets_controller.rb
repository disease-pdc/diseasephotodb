class ImageSetsController < ApplicationController

  before_action :require_image_viewer, only: [:index, :show]

  def index
    @pagesize = 50
    @limit = (params[:limit] || @pagesize).to_i
    @offset = (params[:offset] || 0).to_i
    @image_sets = search_image_sets.limit(@limit).offset(@offset)
    @image_sets_count = search_image_sets.count
    @image_sources = ImageSource.active.order('name desc')
    @metadata_keys = ImageSet.all_metadata_keys
    respond_to do |format|
      format.html 
      format.json { render json: {images: @images} }
    end

  end

  def show
    @image_set = ImageSet.find params[:id]
  end

  def new

  end

  def update

  end

  def create

  end

  def destroy

  end

  def set_images

  end

  def download

  end

  def addtogradingset

  end

  private

    def image_set_params
      params.require(:image_set).permit(:name, :image_source_id, :metadata)
    end

    def search_image_sets
      wheres = ["1=1"]
      wheres_params = {}
      joins = []
      unless params[:metadata_key].blank?
        safe_key = params[:metadata_key].gsub("'", "") # remove single quotes
        wheres << "images.metadata->>'#{safe_key}' like :metadata_value"
        wheres_params[:metadata_value] = "%#{params[:metadata_value]}%"
      end
      unless params[:image_set_ids].blank?
        wheres << 'image_sets.id in (:image_set_ids)'
        wheres_params[:image_set_ids] = params[:image_set_ids]
      end
      unless params[:name].blank?
        wheres << 'name ilike :name'
        wheres_params[:name] = "%#{params[:name]}%"
      end
      unless params[:image_source_id].blank?
        wheres << 'image_source_id = :image_source_id'
        wheres_params[:image_source_id] = params[:image_source_id]
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
      ImageSet.active.joins(joins)
        .order("image_sets.name asc")
        .where(wheres.join(" and "), wheres_params)
    end
end