class AddLunchSpecialToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :lunch_special, :integer
  end
end
