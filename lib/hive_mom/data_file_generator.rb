module HiveMom
  class DataFileGenerator
    attr_reader :file, :readings

    def initialize(file_pointer, readings)
      @file = file_pointer
      @readings = readings
    end

    def call
      file.write(data)
    end

    private

    def data
      CSV.generate do |csv|
        csv << %w(probeid timestamp bot_uptime bot_temp bot_humidity brood_temp
                  brood_humidity hive_lbs)
        readings.each do |r|
          next if r.created_at.nil?
          csv << data_row(r)
        end
      end
    rescue Exception => e
      HiveMom.logger.info(self.class) { "Exception: #{e} : #{e.message}" }
      e.backtrace.each do |line|
        HiveMom.logger.info(self.class) { "Exception: #{line}" }
      end
      raise e
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def data_row(reading)
      probeid = "HIVE_#{reading.hive_id}"
      [
        probeid,
        reading.created_at.utc,
        format_float(reading.bot_uptime),
        format_float(fahrenheit(reading.bot_temp.to_f / 10)),
        format_float(reading.bot_humidity.to_f / 10),
        format_float(fahrenheit(reading.brood_temp.to_f / 10)),
        format_float(reading.brood_humidity.to_f / 10),
        format_float(reading.hive_lbs.to_f / 100)
      ]
    rescue Exception => e
      HiveMom.logger.info(self.class) { "Exception: #{e} : #{e.message}" }
      e.backtrace.each do |line|
        HiveMom.logger.info(self.class) { "Exception: #{line}" }
      end
      raise e
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def fahrenheit(c)
      (c * (9.0 / 5.0)) + 32
    end

    def format_float(float)
      sprintf('%.2f', float.to_f)
    end
  end
end
