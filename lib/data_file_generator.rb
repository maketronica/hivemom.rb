class DataFileGenerator
  attr_reader :file

  def initialize(file_pointer)
    @file = file_pointer
  end

  def call
    file.write(data)
  end

  private

  def data
    CSV.generate do |csv|
      csv << %w(probeid timestamp temperature)
      Reading.order(:created_at).each do |r|
        probeid = "HIVE_#{r.hive_id}_BOT_TEMP"
        csv << [probeid, r.created_at, r.bot_temp]
        probeid = "HIVE_#{r.hive_id}_BROOD_TEMP"
        csv << [probeid, r.created_at, r.brood_temp]
      end
    end
  end
end
