class RemoveSaleDateFromSales < ActiveRecord::Migration[8.0]
  def change
    remove_column :sales, :sale_date, :datetime
  end
end
