require 'spec_helper'
require_relative '../config/environment.rb'

describe Mother do
  let(:mother) { Mother.new }

  describe '#call' do
    context 'when params are empty' do
      let(:env) do
        {
          'QUERY_STRING' => '',
          'rack.input' => double('String::IO')
        }
      end

      it 'returns success' do
        expect(mother.call(env)).to eq(Mother::OKAY)
      end
    end

    context 'when params have reading data' do
      let(:bot_id) { 42 }
      let(:env) do
        {
          'QUERY_STRING' => "bot_id=#{bot_id}",
          'rack.input' => double('String::IO')
        }
      end

      it 'returns success' do
        expect(mother.call(env)).to eq(Mother::OKAY)
      end

      it 'creates a reading' do
        expect { mother.call(env) }
          .to change { Reading.count }
          .by(1)
      end
    end

    context 'when reading is invalid' do
      let(:env) do
        {
          'QUERY_STRING' => 'bot_temp=5',
          'rack.input' => double('String::IO')
        }
      end

      it 'returns invalid' do
        expect(mother.call(env)).to eq(Mother::INVALID)
      end
    end
  end
end
