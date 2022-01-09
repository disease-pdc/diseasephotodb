class CreateImageSources < ActiveRecord::Migration[7.0]
  def change
    create_table :image_sources do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
