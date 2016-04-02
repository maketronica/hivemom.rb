module HiveMom
  describe DataFileGenerator do
    let(:mock_file_pointer) { StringIO.new }
    let(:composite_name) { :instant }
    let(:generator) { DataFileGenerator.new(mock_file_pointer, composite_name) }

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
        reading = readings(:recent_1)
        matcher = "HIVE_#{reading.hive_id},#{reading.created_at.utc}"
        expect(mock_file_pointer.string).to match(/#{matcher}/)
      end
    end
  end
end
