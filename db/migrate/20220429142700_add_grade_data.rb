class AddGradeData < ActiveRecord::Migration[6.1]
  def up
    add_column :user_grading_set_images, :grading_data, :jsonb, null: false, default: {}
    remove_column :user_grading_set_images, :grade
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end