class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.datetime :sale_date
      t.float :sale_price
      t.string :client

      t.timestamps
    end
  end
end
