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
        csv << %w(probeid timestamp bot_temp brood_temp)
        readings.find_each do |r|
          csv << data_row(r)
        end
      end
    end

    def data_row(reading)
      probeid = "HIVE_#{reading.hive_id}"
      [
        probeid,
        reading.created_at,
        reading.bot_temp.to_f / 10,
        reading.brood_temp.to_f / 10
      ]
    end

    def readings
      Reading.where(['created_at > ?', 1.day.ago])
    end
  end
end
