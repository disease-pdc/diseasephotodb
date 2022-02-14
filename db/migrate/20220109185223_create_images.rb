class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|
      t.references :image_source, null: false, foreign_key: true
      t.references :upload_batch, null: false, foreign_key: true
      t.text :filename, null: false
      t.text :mime_type, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
