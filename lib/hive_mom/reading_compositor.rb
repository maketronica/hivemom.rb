module HiveMom
  class ReadingCompositor
    attr_reader :csv_writer, :s3_resourcer

    def initialize(csv_writer = Csv)
      @csv_writer = csv_writer
    end

    def run
      loop do
        composition_sets.each(&:update)
        csvs.each do |csv|
          csv.write_to_file
          csv.upload
        end
        HiveMom.logger.info(self.class) { 'Hybernating' }
        sleep 900
      end
    end

    private

    def composition_sets
      @composition_sets ||= Reading::COMPOSITES.map do |name|
        CompositionSet.new(name, self)
      end
    end

    def csvs
      Reading::COMPOSITES.map do |name|
        csv_writer.new(name, self)
      end
    end
  end
end
