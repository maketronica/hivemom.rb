module HiveMom
  class Reading < ActiveRecord::Base
    validates :bot_id, :hive_id, presence: true
  end
end
