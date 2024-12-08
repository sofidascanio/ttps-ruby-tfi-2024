class AddDeletedAtToSale < ActiveRecord::Migration[8.0]
  def change
    add_column :sales, :is_deleted, :boolean, default: false
  end
end
