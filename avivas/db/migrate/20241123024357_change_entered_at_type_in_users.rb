class ChangeEnteredAtTypeInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :entered_at, :date
  end
end
