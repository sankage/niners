class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.text :serialized_groups

      t.timestamps null: false
    end
  end
end
