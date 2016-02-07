require 'spec_helper'
require_relative '../config/environment.rb'

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

    context 'when POSTed params have reading data' do
      let(:query_string) { "bot_id=42" }
      let(:request_method) { 'POST' }

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
      let(:query_string) { "query[metric]=temperatures" }
      let(:request_method) { 'GET' }
      let(:csv_data) { '12345' }

      it 'returns csv data' do
        expect(mother.call(env)).to eq(csv_data)
      end
    end
  end
end
