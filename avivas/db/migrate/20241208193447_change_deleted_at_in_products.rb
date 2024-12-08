class ChangeDeletedAtInProducts < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :is_deleted, :boolean, default: false
  end
end
