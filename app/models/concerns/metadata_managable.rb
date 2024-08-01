require "active_support/concern"

module MetadataManagable
  extend ActiveSupport::Concern

  def update_metadata metadata, merge=true
    if merge
      self.metadata = (metadata || {}).merge(metadata)
    else
      self.metadata = metadata
    end
    return self.save
  end

end
