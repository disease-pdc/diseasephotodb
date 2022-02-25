class RemoveUploadBatches < ActiveRecord::Migration[6.1]
  def up
    remove_column :images, :upload_batch_id
    drop_table :upload_batches
  end
  def down
    create_table :upload_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.text :name, null: false
      t.datetime :uploaded_at, null: false
      t.timestamps
    end
  end
end
