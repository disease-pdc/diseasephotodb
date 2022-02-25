class AddImagesExifData < ActiveRecord::Migration[6.1]
  def up
    add_column :images, :exif_data, :jsonb, null: false, default: {}
  end
  def down
    remove_column :images, :exif_data
  end
end
