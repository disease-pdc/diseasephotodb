class CreateImageSources < ActiveRecord::Migration[6.1]
  def change
    create_table :image_sources do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
