class AddGradingSetImageUniqueness < ActiveRecord::Migration[6.1]
  def change
    change_table :grading_set_images do |t|
      t.index [:grading_set_id, :image_id], unique: true
    end
  end
end
