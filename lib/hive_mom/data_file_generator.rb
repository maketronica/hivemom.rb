module HiveMom
  class DataFileGenerator
    attr_reader :file

    def initialize(file_pointer)
      @file = file_pointer
    end

    def call
      HiveMom.logger.info(self.class) { 'Generating Data File' }
      file.write(data)
    end

    private

    def data
      CSV.generate do |csv|
        csv << %w(probeid timestamp temperature)
        readings.find_each do |r|
          csv << data_row(r, :bot_temp)
          csv << data_row(r, :brood_temp)
        end
      end
    end

    def data_row(reading, measurement)
      probeid = "HIVE_#{reading.hive_id}_#{measurement.to_s.upcase}"
      [probeid, reading.created_at, reading.send(measurement)]
    end

    def readings
      Reading.where(['created_at > ?', 1.day.ago])
    end
  end
end
