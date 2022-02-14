class CreateImageFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :image_files do |t|
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
