class ChangeEnteredAtTypeInUsers < ActiveRecord::Migration[8.0]
  def up
    change_column :users, :entered_at, :date
  end

  def down
    change_column :users, :entered_at, :datetime
  end
end
