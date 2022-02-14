class CreateGradingSetImages < ActiveRecord::Migration[6.1]
  def change
    create_table :grading_set_images do |t|
      t.references :grading_set, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
