require "active_support/concern"

module MetadataManagable
  extend ActiveSupport::Concern

  def update_metadata metadata, merge=true
    new_metadata = metadata.reject{|k,v| self.fixed_metadata.include?(k)}
    keep_metadata = self.metadata.filter{|k,v| self.fixed_metadata.include?(k)}
    if merge
      self.metadata = self.metadata.merge(new_metadata)
    else
      self.metadata = keep_metadata.merge(new_metadata)
    end
    return self.save
  end

end
