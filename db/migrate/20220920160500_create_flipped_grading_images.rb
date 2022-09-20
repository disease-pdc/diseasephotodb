class CreateFlippedGradingImages < ActiveRecord::Migration[6.1]
  def up
    add_column :grading_sets, :flipped_percent, :integer, null: false, default: 0
    add_column :user_grading_set_images, :flipped, :boolean, null: false, default: false
    add_index :user_grading_set_images, [:user_id, :grading_set_image_id, :flipped], unique: true, name: "index_user_grading_set_images_on_unique"
  end
end
