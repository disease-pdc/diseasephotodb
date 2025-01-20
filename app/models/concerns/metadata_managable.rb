require "active_support/concern"

module MetadataManagable
  extend ActiveSupport::Concern

  def update_metadata metadata, merge=true, update_names=false
    new_metadata = metadata.reject{|k,v| self.fixed_metadata.include?(k)}
    keep_metadata = self.metadata.filter{|k,v| self.fixed_metadata.include?(k)}
    if merge
      self.metadata = self.metadata.merge(new_metadata)
    else
      self.metadata = keep_metadata.merge(new_metadata)
    end
    if update_names
      unless metadata['name'].blank?
        self.metadata['name'] = metadata['name']
        self.name = metadata['name'] if self.name
      end
      unless metadata['filename'].blank?
        self.metadata['filename'] = metadata['filename']
        self.filename = metadata['filename'] if self.filename
      end
    end
    return self.save
  end

end
