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
    end
  end
end
