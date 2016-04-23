module HiveMom
  class ReadingCompositor
    describe CompositionSet do
      let(:name) { 'hour' }
      let(:reading_constructor) { double('Reading') }
      let(:composition) { double('composition', update: true) }
      let(:composition_constructor) { double('Composition', new: composition) }
      let(:compositor) { double('ReadingCompositor') }
      let(:set) do
        CompositionSet.new(name,
                           compositor,
                           reading_constructor,
                           composition_constructor)
      end

      describe '#update' do
        before do
          @hive_ids = %w(hiveA hivaZ)
          allow(reading_constructor)
            .to receive(:pluck)
            .and_return(@hive_ids)
        end

        it 'creates a composition for each hive' do
          @hive_ids.each do |hive_id|
            expect(composition_constructor).to receive(:new).with(hive_id, set)
          end
          set.update
        end

        it 'updates the compositions' do
          expect(composition)
            .to receive(:update)
            .exactly(@hive_ids.count)
            .times
          set.update
        end

        context 'when the name is :instant' do
          let(:name) { :instant }

          it 'does not initialize any compositions' do
            expect(composition_constructor).not_to receive(:new)
            set.update
          end
        end
      end
    end
  end
end
