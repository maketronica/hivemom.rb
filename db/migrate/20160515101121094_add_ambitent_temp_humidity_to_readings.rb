class AddAmbitentTempHumidityToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :ambient_temp, :integer
    add_column :readings, :ambient_humidity, :integer
  end
end
