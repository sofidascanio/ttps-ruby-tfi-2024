class AddSizeToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :size, :string
  end
end
