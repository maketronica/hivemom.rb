describe Mother do
  let(:mother) { Mother.new }

  describe '#call' do
    let(:config) { { 'data_file_path' => 'foo/bar' } }
    let(:data_file_pointer) { double('File.open pointer') }
    let(:data_file_generator) do
      double('DataFileGenerator', call: true)
    end

    before do
      allow(YAML).to receive(:load_file).and_return(config)
      allow(File)
        .to receive(:open)
        .with(config['data_file_path'])
        .and_return(data_file_pointer)
      allow(DataFileGenerator)
        .to receive(:new)
        .with(data_file_pointer)
        .and_return(data_file_generator)
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
        expect(mother.call(env)).to eq(Mother::OKAY)
      end
    end

    context 'when PUT params have reading data' do
      let(:query_string) { 'bot_id=43' }
      let(:request_method) { 'PUT' }

      it 'returns success' do
        expect(mother.call(env)).to eq(Mother::OKAY)
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

      context 'when reading is invalid' do
        before do
          allow(Reading)
            .to receive(:create)
            .and_return(double('reading', valid?: false))
        end

        it 'returns invalid' do
          expect(mother.call(env)).to eq(Mother::INVALID)
        end
      end
    end
  end
end
