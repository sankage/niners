class AddBuffetToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :buffet, :boolean
  end
end
