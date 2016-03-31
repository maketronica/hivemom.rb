class AddCompositeColumnsToReadings < ActiveRecord::Migration
  def up
    add_column :readings, :composite, :string
    add_column :readings, :sampled_at, :datetime

    HiveMom::Reading.update_all('sampled_at = created_at, '\
                                "composite = 'instant'")
  end

  def down
    remove_column :readings, :composite
    remove_column :readings, :sampled_at
  end
end
