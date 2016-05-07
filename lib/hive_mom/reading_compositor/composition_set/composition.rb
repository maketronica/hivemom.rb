module HiveMom
  class ReadingCompositor
    class CompositionSet
      class Composition
        attr_reader :hive_id, :set
        delegate :name, to: :set

        def initialize(hive_id, set)
          @hive_id = hive_id
          @set = set
        end

        def update
          return unless first_reading
          current_composite.update!(composite_params_for_update)
          initialize_next_composite
        end

        private

        def current_composite
          last_composite || initialize_first_composite
        end

        def composite_params_for_update
          composited_columns.map do |column_name|
            sane_readings = readings.where.not(column_name => 0)
            [column_name, sane_readings.average(column_name).to_i]
          end.to_h
        end

        def composited_columns
          Reading.column_names - Reading::UNCOMPOSITED_COLUMNS
        end

        def readings
          Reading.instant
                 .for_hive(hive_id)
                 .where(['sampled_at >= ? AND sampled_at < ?',
                         start_time,
                         end_time])
        end

        def end_time
          start_time + time_span.length
        end

        def start_time
          current_composite.sampled_at
        end

        def initialize_next_composite
          return unless next_reading
          Reading.for_hive(hive_id).composite(name).create(
            sampled_at: start_of_segment(next_reading.sampled_at)
          )
        end

        def last_composite
          Reading.composite(name).for_hive(hive_id).order(:sampled_at).last
        end

        def initialize_first_composite
          Reading.for_hive(hive_id).composite(name).create(
            sampled_at: start_of_segment(first_reading.sampled_at)
          )
        end

        def first_reading
          Reading.instant.for_hive(hive_id).order(:sampled_at).first
        end

        def next_reading
          @next_uncomposited_reading ||=
            Reading.instant
                   .order(:sampled_at)
                   .where(
                     ['sampled_at > ?',
                      last_composite.sampled_at + time_span.length]
                   ).first
        end

        def start_of_segment(datetime)
          time_span.start_for(datetime)
        end

        def time_span
          @time_span ||= TimeSpan.new(name)
        end
      end
    end
  end
end
