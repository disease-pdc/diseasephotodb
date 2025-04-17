class ImageSourcesController < ApplicationController

  before_action :require_image_admin, except: [:image_urls]
  before_action :require_image_viewer, only: [:image_urls]


  def index
    wheres = ["1=1"]
    wheres_params = {}
    unless params[:text].blank?
      wheres << 'name ilike :name'
      wheres_params[:name] = "%#{params[:text]}%"
    end
    @image_sources = ImageSource.order("name asc")
      .where(wheres.join(" and "), wheres_params)
    @image_sources = @image_sources.active if params[:active]
    respond_to do |format|
      format.html 
      format.json { render json: {image_sources: @image_sources} }
    end
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

  def image_urls
    @image_source = ImageSource.find params[:id]
    image_data = []
    @image_source.images.find_each do |image|
      image_data << {
        filename: image.filename,
        url: url_for(image.image_file)
      }
    end
    respond_to do |format|
      format.html 
      format.json { render json: {images: image_data} }
    end
  end
  
  # Queues a participant sync job for the specified participant ID
  def sync_participant
    @image_source = ImageSource.find params[:id]
    participant_id = params[:participant_id]
    email = params[:email]
    
    # Use current_user.id as the sync_user_id
    sync_user_id = current_user.id
    
    # Validate required parameters
    if participant_id.blank? || email.blank?
      flash.alert = "Participant ID and email are required"
      return redirect_to image_source_path(@image_source)
    end
    
    # Queue the sync job
    ParticipantSyncJob.perform_async(
      participant_id,
      @image_source.id,
      sync_user_id,
      email
    )
    
    flash.notice = "Sync queued for participant #{participant_id}"
    redirect_to image_source_path(@image_source)
  end

  private

    def image_source_params
      params.require(:image_source).permit(
        :name, 
        :active,
        :create_image_sets,
        :create_image_sets_metadata_field
      )
    end

    def metadata_params
      params.require(:filename, metadata: [])
    end

end
