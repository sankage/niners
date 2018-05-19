class AddStandbyToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :on_standby, :boolean, default: false
  end
end
