class AddReadingIndexes < ActiveRecord::Migration
  def change
    add_column :readings, :hourly_group_key, :string
    add_column :readings, :daily_group_key, :string

    add_index :readings, [:hourly_group_key, :hive_id]
    add_index :readings, [:daily_group_key, :hive_id]
    
    HiveMom::Reading.reset_column_information
    HiveMom::Reading.find_each do |reading|
      reading.update(hourly_group_key: => reading.created_at.strftime('%Y-%m-%d %H'), daily_group_key: reading.created_at.strftime('%Y-%m-%d'))
    end
  end
end
