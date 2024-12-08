class AddDeletedAtToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_deleted, :boolean, default: false
  end
end
