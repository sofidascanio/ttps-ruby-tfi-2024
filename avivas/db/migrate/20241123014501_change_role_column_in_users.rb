class ChangeRoleColumnInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :role, :integer, default: 2, null: false
  end
end
