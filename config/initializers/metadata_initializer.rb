Rails.application.config.x.imagery_metadata_config.locked_keys = 
  (ENV['LOCKED_METADATA_KEYS'] || '').split(',').map(&:squish)