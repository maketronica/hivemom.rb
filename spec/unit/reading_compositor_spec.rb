module HiveMom
  describe ReadingCompositor do
    let(:s3_object) { double('S3 object', put: true) }
    let(:s3_bucket) { double('S3 bucket', object: s3_object) }
    let(:s3_client) { double('S3 client', bucket: s3_bucket) }
    let(:s3_resourcer) { double('Aws::S3::Resource', new: s3_client) }
    let(:csv_writer) { double('csv_writer', write_to_file: true, upload: true) }
    let(:csv_writer_constructor) { double('Csv', new: csv_writer) }
    let(:compositor) do
      ReadingCompositor.new(s3_resourcer, csv_writer_constructor)
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
