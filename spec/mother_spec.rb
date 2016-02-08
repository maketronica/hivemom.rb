require 'spec_helper'

describe Mother do
  let(:mother) { Mother.new }

  describe '#call' do
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

    context 'when GET params request temperatures' do
      let(:query_string) { 'query[metric]=temperatures' }
      let(:request_method) { 'GET' }
      let(:csv_data) { '12345' }

      it 'returns csv data' do
        expect(mother.call(env)[2]).to be_a(String)
      end
    end
  end
end
