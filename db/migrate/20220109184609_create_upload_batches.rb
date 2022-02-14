class CreateUploadBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :upload_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.text :name, null: false
      t.datetime :uploaded_at, null: false

      t.timestamps
    end
  end
end
