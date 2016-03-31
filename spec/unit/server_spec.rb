module HiveMom
  describe Server do
    let(:mother) { Server.new }

    describe '.call' do
      let(:config) { HiveMom.config }

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

        it 'creates a instant composite reading' do
          expect { mother.call(env) }
            .to change { Reading.composite(:instant).count }
            .by(1)
        end

        it 'sets the reading sampled_at to Time.now' do
          Timecop.freeze do
            mother.call(env)
            expect(Reading.composite(:instant).last.sampled_at)
              .to be_within(1.second)
              .of(Time.now)
          end
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
