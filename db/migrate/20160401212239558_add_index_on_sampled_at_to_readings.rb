class AddIndexOnSampledAtToReadings < ActiveRecord::Migration
  def change
    add_index :readings, :sampled_at
  end
end
