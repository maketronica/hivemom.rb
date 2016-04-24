module HiveMom
  describe ReadingCompositor do
    let(:csv_writer) { double('csv_writer', write_to_file: true, upload: true) }
    let(:csv_writer_constructor) { double('Csv', new: csv_writer) }
    let(:compositor) do
      ReadingCompositor.new(csv_writer_constructor)
    end

    it 'instantiates' do
      expect(compositor).to be_a(ReadingCompositor)
    end

    context '#run' do
      before do
        allow(compositor).to receive(:loop).and_yield
        allow(compositor).to receive(:sleep)
      end

      it 'writes the file' do
        expect(csv_writer).to receive(:write_to_file)
        compositor.run
      end

      it 'uploads the file' do
        expect(csv_writer).to receive(:upload)
        compositor.run
      end
    end
  end
end
