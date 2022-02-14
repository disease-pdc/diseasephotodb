class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.text :email, null: false
      t.text :login_token_hash
      t.datetime :login_token_expires_at
      t.boolean :admin, null: false, default: false
      t.boolean :image_viewer, null: false, default: false
      t.boolean :image_admin, null: false, default: false
      t.boolean :grader, null: false, default: false

      t.timestamps
    end
  end
end
