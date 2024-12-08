class AddDeletedAtToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :deleted_at, :boolean, default: false
  end
end
