module HiveMom
  class Reading < ActiveRecord::Base
    validates :bot_id, presence: true
  end
end