class UpdateGradingSetImagePolymorphic < ActiveRecord::Migration[6.1]

  def up
    add_column :grading_set_images, :gradeable_type, :string
    add_column :grading_set_images, :gradeable_id, :integer
    add_index :grading_set_images, [:gradeable_type, :gradeable_id]
    add_index :grading_set_images, [:grading_set_id, :gradeable_id], unique: true
    execute %(
      update grading_set_images set 
        gradeable_type = 'Image', 
        gradeable_id = image_id
      ;
    )
    remove_column :grading_set_images, :image_id
    change_column_null :grading_set_images, :gradeable_type, false
    change_column_null :grading_set_images, :gradeable_id, false
  end

  def down
    add_column :grading_set_images, :image_id, :integer
    execute %(
      update grading_set_images set image_id = gradeable_id
      ;
    )
    change_column_null :grading_set_images, :image_id, false
    remove_column :grading_set_images, :gradeable_type
    remove_column :grading_set_images, :gradeable_id
    add_index :grading_set_images, [:grading_set_id, :image_id], unique: true
  end

end
