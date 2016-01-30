class CreateReadingsTable < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.integer :hive_id
      t.integer :bot_id
      t.integer :bot_uptime
      t.integer :bot_temp
      t.integer :bot_humidity
      t.integer :brood_temp
      t.integer :brood_humidity
      t.timestamps null: false
    end
  end
end
