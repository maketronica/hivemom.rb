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

    it 'writes recent readings to the file pointer' do
      reading = readings(:recent_1)
      matcher = "HIVE_#{reading.hive_id}_BOT_TEMP,#{reading.created_at}"
      expect(mock_file_pointer.string).to match(/#{matcher}/)
    end

    it 'does not write older readings to the file pointer' do
      reading = readings(:yesterday_1)
      matcher = "HIVE_#{reading.hive_id}_BOT_TEMP,#{reading.created_at}"
      expect(mock_file_pointer.string).not_to match(/#{matcher}/)
    end
  end
end
