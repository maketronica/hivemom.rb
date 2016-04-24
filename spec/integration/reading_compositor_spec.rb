module HiveMom
  describe ReadingCompositor do
    let(:hive_id) { 2 }
    let(:config) { HiveMom.config }
    let(:csv_folder) { config.csv_folder }
    let(:compositor) { ReadingCompositor.new }
    let(:file_pointers) do
      {
        instant: double('instant_file_pointer', write: true),
        hour: double('hour_file_pointer', write: true),
        day: double('day_file_pointer', write: true)
      }
    end
    let(:s3_objects) do
      {
        instant: double('instant_s3_object', put: true),
        hour: double('hour_s3_object', put: true),
        day: double('day_s3_object', put: true)
      }
    end
    let(:s3_bucket) { double(:s3_bucket) }
    let(:s3_resource) { double('s3_resource', bucket: s3_bucket) }

    context '#run' do
      before do
        allow(Aws::S3::Resource)
          .to receive(:new)
          .with(region: config.aws_region)
          .and_return(s3_resource)
        allow(File).to receive(:open).and_call_original
        allow(compositor).to receive(:loop).and_yield
        allow(compositor).to receive(:sleep)
        %w(instant hour day).each do |span|
          allow(File)
            .to receive(:open)
            .with("#{csv_folder}/#{span}_data.csv", 'w')
            .and_return(file_pointers[span.to_sym])
          allow(s3_bucket)
            .to receive(:object)
            .with("#{span}_data.csv")
            .and_return(s3_objects[span.to_sym])
        end
        Reading.instant.for_hive(hive_id).create(
          sampled_at: Time.now,
          bot_temp: 42,
          brood_temp: 42,
          bot_humidity: 42,
          brood_humidity: 42
        )
      end

      it 'creates composite hour readings' do
        expect { compositor.run }.to change { Reading.composite(:hour).count }
      end

      it 'creates composite day readings' do
        expect { compositor.run }.to change { Reading.composite(:day).count }
      end

      it 'writes composite instant csv file' do
        expect(file_pointers[:instant]).to receive(:write).with(/HIVE_2/)
        compositor.run
      end

      it 'writes composite hour csv file' do
        expect(file_pointers[:hour]).to receive(:write).with(/HIVE_2/)
        compositor.run
      end

      it 'writes composite day csv file' do
        expect(file_pointers[:day]).to receive(:write).with(/HIVE_2/)
        compositor.run
      end

      it 'uploads instant csv file to s3' do
        expect(s3_objects[:instant]).to receive(:put).with(body: /HIVE_2/)
        compositor.run
      end

      it 'uploads hour csv file to s3' do
        expect(s3_objects[:hour]).to receive(:put).with(body: /HIVE_2/)
        compositor.run
      end

      it 'uploads day csv file to s3' do
        expect(s3_objects[:day]).to receive(:put).with(body: /HIVE_2/)
        compositor.run
      end
    end
  end
end
