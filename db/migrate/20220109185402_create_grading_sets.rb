class CreateGradingSets < ActiveRecord::Migration[6.1]
  def change
    create_table :grading_sets do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
