module HiveMom
  class ReadingCompositor
    class CompositionSet
      describe Composition do
        let(:hive_id) { 2 }
        let(:name) { 'day' }
        let(:composition_set) { double('composition_set', name: name) }
        let(:composition) { Composition.new(hive_id, composition_set) }

        it 'instantiates' do
          expect(composition).to be_a(Composition)
        end

        context '#update' do
          context 'when there is not a current composite' do
            before do
              Reading.composite(name).destroy_all
            end

            context 'when there are no readings' do
              before do
                Reading.destroy_all
              end

              it 'does not initialize a new composite' do
                expect { composition.update }
                  .not_to change { Reading.composite(name).count }
              end
            end

            context 'when there is at least one reading' do
              it 'initializes a new composite and updates it' do
                expect { composition.update }
                  .to change { Reading.composite(name).count }
              end
            end
          end

          context 'when there is a current composite' do
            it 'updates the current composite' do
              expect { composition.update }
                .to change { readings(:yesterday_composite).reload.bot_temp }
                .from(2).to(20)
            end
          end

          context 'when there is not a reading after the current composite' do
            it' does not initialize the next composite' do
              expect { composition.update }
                .not_to change { Reading.composite(name).count }
            end
          end

          context 'when there is a reading after the current composite' do
            before do
              Reading.instant.for_hive(hive_id).create(
                sampled_at: Time.now,
                bot_temp: 42,
                brood_temp: 42,
                bot_humidity: 42,
                brood_humidity: 42
              )
            end

            it 'initializes the next composite' do
              expect { composition.update }
                .to change { Reading.composite(name).count }
            end
          end
        end
      end
    end
  end
end
