describe DataFileGenerator do
  let(:mock_file_pointer) { StringIO.new }
  let(:generator) { DataFileGenerator.new(mock_file_pointer) }

  it 'instantiates' do
    expect(generator).to be_a(DataFileGenerator)
  end

  describe '#call' do
    before do
      generator.call
    end

    it 'writes a header to the file pointer' do
      header_regex = /^probeid,timestamp,temperature$/
      expect(mock_file_pointer.string).to match(header_regex)
    end

    it 'writes readings to the file pointer' do
      probe_id = "HIVE_#{readings(:first).hive_id}_BOT_TEMP"
      expect(mock_file_pointer.string).to match(/#{probe_id}/)
    end
  end
end
