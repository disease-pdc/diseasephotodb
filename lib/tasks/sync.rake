require_relative '../../lib/odtsync'

# All sync methods and constants are now in the Odtsync module.
# Use Odtsync.method_name to call them from here.

namespace :sync do

  desc "Sync patients on profile"
  task :patients, [:email, :image_source_id, :sync_user_id, :last_updated_days, :start_pid, :validate] => :environment do |task, args|
    email = args[:email]
    
    # Convert validate string to boolean if needed
    validate_param = %w(1 true yes t y).include?(args[:validate])
    
    # Create params hash for sync_patients
    sync_params = {
      image_source_id: args[:image_source_id],
      sync_user_id: args[:sync_user_id],
      last_updated_days: args[:last_updated_days],
      start_pid: args[:start_pid],
      validate: validate_param
    }

    begin
      # Create Odtsync instance and perform sync with params hash
      syncer = Odtsync.new(email)
      synced_patients = syncer.sync_patients(sync_params)
      
      # Report results
      puts "Sync completed. Synced #{synced_patients.size} patients."
    rescue => exception
      puts exception.backtrace
      raise # always reraise
    ensure
      # Cleanup is handled in the sync_patients method
    end
  end

  desc "Sync a specific patient by ID"
  task :patient, [:email, :participant_id, :image_source_id, :sync_user_id] => :environment do |task, args|
    email = args[:email]
    participant_id = args[:participant_id]
    image_source_id = args[:image_source_id]
    sync_user_id = args[:sync_user_id]
    
    unless email && participant_id && image_source_id && sync_user_id
      puts "Error: All parameters are required: email, participant_id, image_source_id, sync_user_id"
      exit 1
    end
    
    begin
      # Create Odtsync instance and sync the specific patient
      syncer = Odtsync.new(email)
      result = syncer.sync_patient(participant_id, image_source_id, sync_user_id)
      
      if result
        puts "Successfully synced patient #{participant_id}"
      else
        puts "No data synced for patient #{participant_id}"
      end
    rescue => exception
      puts exception.backtrace
      raise # always reraise
    end
  end

end
