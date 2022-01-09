class CreateGradingSets < ActiveRecord::Migration[7.0]
  def change
    create_table :grading_sets do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
