class CreateUserGradingSets < ActiveRecord::Migration[6.1]
  def change
    create_table :user_grading_sets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :grading_set, null: false, foreign_key: true

      t.timestamps
    end
  end
end
