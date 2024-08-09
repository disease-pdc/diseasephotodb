class CreateImageSets < ActiveRecord::Migration[6.1]
  def change
    
    create_table :image_sets do |t|
      t.references :image_source, null: false, foreign_key: true
      t.text :name, null: false
      t.text :source_metadata_name, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
    add_index :image_sets, [:image_source_id, :source_metadata_name], unique: true

    create_table :image_set_images do |t|
      t.references :image_set, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
    add_index :image_set_images, [:image_set_id, :image_id], unique: true
  end
end