class AddHiveLbsColumn < ActiveRecord::Migration
  def change
    add_column :readings, :hive_lbs, :integer
  end
end
