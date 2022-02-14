class AddImageSourcesActive < ActiveRecord::Migration[6.1]
  def up
    add_column :image_sources, :active, :boolean, null: false, default: true
  end
  def down
    drop_column :image_sources, :active
  end
end
