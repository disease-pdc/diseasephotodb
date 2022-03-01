class DropImageFiles < ActiveRecord::Migration[6.1]
  def up
    drop_table :image_files
  end
  def down
    create_table :image_files do |t|
      t.references :image, null: false, foreign_key: true
      t.timestamps
    end
  end
end
