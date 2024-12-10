class AddEnteredAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :entered_at, :date, null: false
  end
end
