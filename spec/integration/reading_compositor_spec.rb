module HiveMom
  describe ReadingCompositor do
    let(:hive_id) { 2 }
    let(:config) { HiveMom.config }
    let(:csv_folder) { config.csv_folder }
    let(:compositor) { ReadingCompositor.new }
    let(:file_pointers) do
      Reading::COMPOSITES.map do |name|
        [name, double("#{name}_file_pointer", write: true)]
      end.to_h
    end
    let(:s3_objects) do
      Reading::COMPOSITES.map do |name|
        [name, double("#{name}_s3_object", put: true)]
      end.to_h
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
        Reading::COMPOSITES.each do |span|
          allow(File)
            .to receive(:open)
            .with("#{csv_folder}/#{span}_data.csv", 'w')
            .and_return(file_pointers[span])
          allow(s3_bucket)
            .to receive(:object)
            .with("#{span}_data.csv")
            .and_return(s3_objects[span])
        end
        Reading.instant.for_hive(hive_id).create(
          sampled_at: Time.now,
          bot_uptime: 1,
          bot_temp: 42,
          brood_temp: 42,
          bot_humidity: 42,
          brood_humidity: 42
        )
      end

      Reading::COMPOSITES.each do |name|
        next if name == 'instant'
        it "creates #{name} composite readings" do
          expect { compositor.run }
            .to change { Reading.composite(name).count },
                lambda {
                  "Expected #{name} compositions to change, but is still "\
                  "#{Reading.composite(name).count}"
                }
        end
      end

      it 'writes composite csv files' do
        Reading::COMPOSITES.each do |name|
          expect(file_pointers[name]).to receive(:write).with(/HIVE_2/)
        end
        compositor.run
      end

      it 'uploads csv files to s3' do
        Reading::COMPOSITES.each do |name|
          expect(s3_objects[name]).to receive(:put).with(body: /HIVE_2/)
        end
        compositor.run
      end
    end
  end
end
