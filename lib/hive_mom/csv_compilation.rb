module HiveMom
  class CsvCompilation
    attr_reader :composite_name

    def initialize(composite_name)
      @composite_name = composite_name
    end

    def content
      CSV.generate do |csv|
        csv << %w(probeid timestamp bot_uptime bot_temp bot_humidity brood_temp
                  brood_humidity hive_lbs)
        readings.each do |r|
          csv << data_row(r)
        end
      end
    end

    private

    def readings
      @readings ||=
        Reading.composite(composite_name)
               .where(['sampled_at > ?', max_composite_readings_age])
    end

    def max_composite_readings_age
      case composite_name.to_sym
      when :instant then 24.hours.ago
      when :hour then 60.days.ago
      when :day then 4.years.ago
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

    def fahrenheit(c)
      (c * (9.0 / 5.0)) + 32
    end
  end
end
