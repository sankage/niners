class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :name
      t.boolean :walker
      t.boolean :rider

      t.timestamps null: false
    end
  end
end
