module HiveMom
  describe Server do
    let(:s3_object) { double('S3 object', upload_file: true) }
    let(:s3_bucket) { double('S3 bucket', object: s3_object) }
    let(:s3_client) { double('S3 client', bucket: s3_bucket) }
    let(:s3_resourcer) { double('Aws::S3::Resource', new: s3_client) }
    let(:mother) { Server.new(s3_resourcer) }

    describe '.call' do
      let(:config) { HiveMom.config }
      let(:data_file_pointer) { double('File.open pointer', close: true) }
      let(:reading_relation) { double('reading relation') }
      let(:reading_group) do
        double('reading group', average: { '01-01-16' => 42 })
      end
      let(:data_file_generator) { double('DataFileGenerator', call: true) }

      before do
        allow(Reading)
          .to receive(:where)
          .and_return(reading_relation)
        allow(File)
          .to receive(:open)
          .with("#{config.csv_folder}/minutely_data.csv", 'w')
          .and_return(data_file_pointer)
        allow(File)
          .to receive(:open)
          .with("#{config.csv_folder}/hourly_data.csv", 'w')
          .and_return(data_file_pointer)
        allow(File)
          .to receive(:open)
          .with("#{config.csv_folder}/daily_data.csv", 'w')
          .and_return(data_file_pointer)
        allow(DataFileGenerator)
          .to receive(:new)
          .and_return(data_file_generator)
        allow(reading_relation)
          .to receive(:group)
          .and_return(reading_group)
      end

      let(:env) do
        {
          'REQUEST_METHOD' => request_method,
          'QUERY_STRING' => query_string,
          'rack.input' => double('String::IO', read: query_string, rewind: true)
        }
      end

      context 'when params are empty' do
        let(:query_string) { '' }
        let(:request_method) { 'GET' }

        it 'returns success' do
          expect(mother.call(env)).to eq(Server::OKAY)
        end
      end

      context 'when PUT params have reading data' do
        let(:query_string) { 'bot_id=43&hive_id=1' }
        let(:request_method) { 'PUT' }

        it 'returns success' do
          expect(mother.call(env)).to eq(Server::OKAY)
        end

        it 'creates a reading' do
          expect { mother.call(env) }
            .to change { Reading.count }
            .by(1)
        end

        it 'generates the csv file' do
          expect(data_file_generator).to receive(:call)
          mother.call(env)
        end

        it 'closes the file pointer' do
          expect(data_file_pointer).to receive(:close)
          mother.call(env)
        end

        context 'when reading is invalid' do
          before do
            allow(Reading)
              .to receive(:create)
              .and_return(double('reading', valid?: false))
          end

          it 'returns invalid' do
            expect(mother.call(env)).to eq(Server::INVALID)
          end
        end
      end
    end
  end
end
