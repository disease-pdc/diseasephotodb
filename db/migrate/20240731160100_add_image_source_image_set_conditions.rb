class AddImageSourceImageSetConditions < ActiveRecord::Migration[6.1]
  def change
    add_column :image_sources, :create_image_sets, :string
    add_column :image_sources, :create_image_sets_metadata_field, :string
  end
end