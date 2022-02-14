class CreateUserGradingSetImages < ActiveRecord::Migration[6.1]
  def change
    create_table :user_grading_set_images do |t|
      t.references :user, null: false, foreign_key: true
      t.references :grading_set_image, null: false, foreign_key: true
      t.integer :grade, null: false

      t.timestamps
    end
  end
end
