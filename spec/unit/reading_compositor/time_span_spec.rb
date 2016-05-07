module HiveMom
  class ReadingCompositor
    describe TimeSpan do
      let(:name) { '1_hour' }
      let(:time_span) { TimeSpan.new(name) }
      describe '#length' do
        it 'is 1 hour' do
          expect(time_span.length).to eq(1.hour)
        end

        context 'when name is 8_minutes' do
          let(:name) { '8_minutes' }

          it 'is 8 minutes' do
            expect(time_span.length).to eq(8.minutes)
          end
        end

        context 'when name is 42_months' do
          let(:name) { '42_months' }

          it 'is 42 months' do
            expect(time_span.length).to eq(42.months)
          end
        end
      end
    end
  end
end
