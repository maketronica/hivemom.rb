module HiveMom
  class ReadingCompositor
    class CsvCompilation
      MAX_RECORDS_PER_FILE = 100
      RESCUE_WAIT_BASE_TIME = 2

      attr_reader :composite_name, :previous_attempt_count

      def initialize(composite_name)
        @composite_name = composite_name
        @previous_attempt_count = 0
      end

      def content
        @content ||= CSV.generate do |csv|
          csv << %w(probeid timestamp bot_uptime bot_temp bot_humidity
                    brood_temp brood_humidity hive_lbs)
          readings.each do |r|
            csv << data_row(r)
          end
        end
      rescue ActiveRecord::StatementInvalid => e
        process_rescued_error(e)
      end

      private

      def readings
        @readings ||=
          Reading.composite(composite_name)
                 .where(['sampled_at > ?', max_composite_readings_age])
                 .where.not(bot_uptime: 0)
      end

      def max_composite_readings_age
        case composite_name
        when 'instant' then MAX_RECORDS_PER_FILE.minutes.ago
        else (time_span.length.to_i * MAX_RECORDS_PER_FILE).seconds.ago
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def data_row(reading)
        probeid = "HIVE_#{reading.hive_id}"
        [
          probeid,
          reading.sampled_at.utc,
          reading.bot_uptime.to_f / 1440,
          fahrenheit(reading.bot_temp.to_f / 10),
          reading.bot_humidity.to_f / 10,
          fahrenheit(reading.brood_temp.to_f / 10),
          reading.brood_humidity.to_f / 10,
          reading.hive_lbs.to_f / 100
        ]
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def process_rescued_error(e)
        raise e unless e.message =~ /SQLite3::BusyException/
        HiveMom.logger.error(self.class) do
          "Compositor Rescuing from #{e.class} : #{e.message}\n"\
          "Compositor Waiting for #{rescue_wait_time} seconds."
        end
        sleep rescue_wait_time
        increment_previous_attempt_count
      end

      def fahrenheit(c)
        (c * (9.0 / 5.0)) + 32
      end

      def time_span
        @time_span ||= TimeSpan.new(composite_name)
      end

      def rescue_wait_time
        RESCUE_WAIT_BASE_TIME**previous_attempt_count
      end

      def increment_previous_attempt_count
        @previous_attempt_count += 1
      end
    end
  end
end
