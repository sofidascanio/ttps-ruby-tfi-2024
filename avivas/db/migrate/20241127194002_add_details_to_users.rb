class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :telephone, :string
    add_column :users, :role, :integer, default: 2, null: false
    add_index :users, :username, unique: true
  end
end
