class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.text :serialized_groups

      t.timestamps null: false
    end
  end
end
