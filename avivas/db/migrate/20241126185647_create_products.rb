class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.float :price
      t.integer :stock
      t.string :color
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
