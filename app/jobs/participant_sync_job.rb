require_relative '../../lib/odtsync'

class ParticipantSyncJob
  include Sidekiq::Worker
  
  # Configure job options:
  # - Place on a dedicated queue with concurrency=1 (configured in sidekiq.yml)
  # - Allow retries with exponential backoff
  sidekiq_options queue: 'patient_sync'
  
  # @param participant_id [String] ID of the participant to sync
  # @param image_source_id [String/Integer] ID of the image source
  # @param sync_user_id [String/Integer] ID of the sync user
  # @param email [String] Email to use for sync credentials
  def perform(participant_id, image_source_id, sync_user_id, email)
    # Create Odtsync instance with the provided email
    syncer = Odtsync.new(email)
    
    # Sync the specific patient and get the result
    result = syncer.sync_patient(participant_id, image_source_id, sync_user_id)
    
    # Log the result
    if result
      logger.info "Successfully synced participant #{participant_id}"
    else
      logger.warn "No data synced for participant #{participant_id}"
    end
    
    # Return the result for testing purposes
    result
  end
end
