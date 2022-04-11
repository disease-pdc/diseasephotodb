class AddUserGradingSetUniqueness < ActiveRecord::Migration[6.1]
  def change
    change_table :user_grading_sets do |t|
      t.index [:user_id, :grading_set_id], unique: true
    end
  end
end
