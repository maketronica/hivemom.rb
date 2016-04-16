module HiveMom
  describe ReadingCompositor do
    let(:s3_object) { double('S3 object', put: true) }
    let(:s3_bucket) { double('S3 bucket', object: s3_object) }
    let(:s3_client) { double('S3 client', bucket: s3_bucket) }
    let(:s3_resourcer) { double('Aws::S3::Resource', new: s3_client) }
    let(:csv_compilation) { double('csv_compilation', content: 'csv content') }
    let(:csv_compiler) { double('CsvCompilation', new: csv_compilation) }
    let(:compositor) { ReadingCompositor.new(s3_resourcer, csv_compiler) }

    it 'instantiates' do
      expect(compositor).to be_a(ReadingCompositor)
    end

    context '#run' do
      let(:data_file_pointer) { double('File.open pointer', close: true) }

      before do
        allow(compositor).to receive(:loop).and_yield
        allow(compositor).to receive(:sleep)
        allow(File)
          .to receive(:open)
          .and_return(data_file_pointer)
        allow(data_file_pointer)
          .to receive(:write)
          .with(csv_compilation.content)
      end

      context 'when there are no hourly composites' do
        it 'creates one for the oldest instant reading' do
          expect { compositor.run }
            .to change { Reading.composite(:hour).count }
          expect(Reading.composite(:hour).first.sampled_at)
            .to eq(Reading.instant.order(:sampled_at)
                          .first.sampled_at.beginning_of_hour)
        end
      end

      context 'when there are existing hourly composites' do
        let(:reading) { Reading.order(:sampled_at).last }

        before do
          @existing_composite = Reading.composite(:hour).create(
            composite: 'hour',
            hive_id: reading.hive_id,
            sampled_at: reading.sampled_at.beginning_of_hour)
        end

        context 'when the latest instant reading is for the '\
                'latest existing hourly composite' do
          it 'does not create a new composite' do
            expect { compositor.run }
              .not_to change { Reading.composite(:hour).count }
          end

          it 'updates the existing composite' do
            expect { compositor.run }
              .to change { @existing_composite.reload.bot_temp }
          end
        end

        context 'when the latest instant reading is for a '\
                'non-existant composite' do
          before do
            @new_reading = Reading.instant.create(
              hive_id: reading.hive_id,
              sampled_at: 2.hours.from_now,
              bot_temp: 24
            )
          end

          it 'creates a new composite' do
            expect { compositor.run }
              .to change { Reading.composite(:hour).count }
          end

          it 'updates the existing composite' do
            expect { compositor.run }
              .to change { @existing_composite.reload.bot_temp }
          end
        end
      end

      context 'when there are no daily composites' do
        it 'creates one for the oldest instant reading' do
          expect { compositor.run }
            .to change { Reading.composite(:day).count }
          expect(Reading.composite(:day).first.sampled_at)
            .to eq(Reading.instant.order(:sampled_at)
                          .first.sampled_at.beginning_of_day)
        end
      end

      context 'when there are existing daily composites' do
        let(:reading) { Reading.order(:sampled_at).last }

        before do
          @existing_composite = Reading.composite(:hour).create(
            composite: 'day',
            hive_id: reading.hive_id,
            sampled_at: reading.sampled_at.beginning_of_day)
        end

        context 'when the latest instant reading is for the '\
                'latest existing daily composite' do
          it 'does not create a new composite' do
            expect { compositor.run }
              .not_to change { Reading.composite(:day).count }
          end

          it 'updates the existing composite' do
            expect { compositor.run }
              .to change { @existing_composite.reload.bot_temp }
          end
        end

        context 'when the latest instant reading is for a '\
                'non-existant composite' do
          before do
            @new_reading = Reading.instant.create(
              hive_id: reading.hive_id,
              sampled_at: 2.days.from_now,
              bot_temp: 24
            )
          end

          it 'creates a new composite' do
            expect { compositor.run }
              .to change { Reading.composite(:day).count }
          end

          it 'updates the existing composite' do
            expect { compositor.run }
              .to change { @existing_composite.reload.bot_temp }
          end
        end
      end

      it 'generates the csv file' do
        expect(data_file_pointer)
          .to receive(:write)
          .with(csv_compilation.content)
        compositor.run
      end

      it 'closes the file pointer' do
        expect(data_file_pointer).to receive(:close)
        compositor.run
      end

      it 'uploads csv data' do
        expect(s3_object)
          .to receive(:put)
          .with(body: csv_compilation.content)
        compositor.run
      end
    end
  end
end
