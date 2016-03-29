module HiveMom
  class DataFileGenerator
    attr_reader :file, :readings

    def initialize(file_pointer, readings)
      @file = file_pointer
      @readings = readings
    end

    def call
      HiveMom.logger.info(self.class) { 'Generating Data File' }
      file.write(data)
    end

    private

    def data
      CSV.generate do |csv|
        csv << %w(probeid timestamp bot_uptime bot_temp bot_humidity brood_temp
                  brood_humidity hive_lbs)
        readings.each do |r|
          csv << data_row(r)
        end
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def data_row(reading)
      probeid = "HIVE_#{reading.hive_id}"
      [
        probeid,
        reading.created_at.utc,
        reading.bot_uptime,
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
