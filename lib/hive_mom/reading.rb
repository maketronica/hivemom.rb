module HiveMom
  class Reading < ActiveRecord::Base
    validates :bot_id, :hive_id, presence: true

    before_save :set_group_keys

    private

    def set_group_keys
      self.hourly_group_key = Time.now.utc.strftime('%Y-%m-%d %H')
      self.daily_group_key = Time.now.utc.strftime('%Y-%m-%d')
    end
  end
end
