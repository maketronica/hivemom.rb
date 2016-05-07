module HiveMom
  class Reading < ActiveRecord::Base
    COMPOSITES = %w(instant 15_minutes 1_hour 1_day 1_week 1_month).freeze
    UNCOMPOSITED_COLUMNS = %w(id hive_id bot_id sampled_at created_at
                              updated_at composite).freeze
    validates :hive_id, presence: true
    validates :composite, inclusion: { in: COMPOSITES }
    scope :composite, ->(name) { where(composite: name) }
    scope :instant, -> { where(composite: 'instant') }
    scope :for_hive, ->(hive_id) { where(hive_id: hive_id) }
  end
end
