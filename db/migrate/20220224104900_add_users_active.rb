class AddUsersActive < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :active, :boolean, null: false, default: true
  end
  def down
    remove_column :users, :active
  end
end
