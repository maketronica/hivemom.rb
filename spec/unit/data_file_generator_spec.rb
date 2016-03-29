module HiveMom
  describe DataFileGenerator do
    let(:mock_file_pointer) { StringIO.new }
    let(:default_reading_attrs) do
      {
        bot_uptime: 10,
        bot_temp: 5,
        bot_humidity: 12,
        brood_temp: 6,
        brood_humidity: 13,
        hive_lbs: 100
      }
    end
    let(:mock_readings) do
      [
        double('reading',
               default_reading_attrs.merge(created_at: 1.day.ago,
                                           hive_id: 42)),
        double('reading',
               default_reading_attrs.merge(created_at: 1.hour.ago,
                                           hive_id: 6000))
      ]
    end
    let(:generator) { DataFileGenerator.new(mock_file_pointer, mock_readings) }

    it 'instantiates' do
      expect(generator).to be_a(DataFileGenerator)
    end

    describe '#call' do
      before do
        generator.call
      end

      it 'writes a header to the file pointer' do
        header_regex = /^probeid,timestamp/
        expect(mock_file_pointer.string).to match(header_regex)
      end

      it 'writes readings to the file pointer' do
        reading = mock_readings[0]
        matcher = "HIVE_#{reading.hive_id},#{reading.created_at.utc}"
        expect(mock_file_pointer.string).to match(/#{matcher}/)
      end
    end
  end
end
