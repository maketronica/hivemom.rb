module HiveMom
  describe ReadingComposition do
    let(:span) { :hourly }
    let(:composition) { ReadingComposition.new(span) }

    it 'instantiates' do
      expect(composition).to be_a(ReadingComposition)
    end

    context '.composite_readings' do
      before do
        Reading.create(created_at: 1.day.ago, bot_id: 42, hive_lbs: 21)
        @result = composition.composite_readings
      end

      it 'returns an array of CompositeReadings' do
        expect(@result.first).to be_a(ReadingComposition::CompositeReading)
      end

      context 'composite reading' do
        let(:composition) { ReadingComposition.new(span) }
        let(:composite_reading) { composition.composite_readings.first }

        it 'get composed methods from composition' do
          expect(composite_reading.hive_lbs).to eq(21)
        end
      end

      context 'minutely composites' do
        let(:span) { :minutely }

        before do
          @reading1 = Reading.create(created_at: 23.hours.ago,
                                     bot_id: 42, hive_lbs: 22)
          @reading2 = Reading.create(created_at: 26.hours.ago,
                                     bot_id: 43, hive_lbs: 23)
          @result = composition.composite_readings
        end

        it 'returns readings for the last day' do
          expect(@result).to include(@reading1)
          expect(@result).not_to include(@reading2)
        end
      end

      context 'hourly composites' do
        let(:span) { :hourly }

        before do
          Reading.create(created_at: 59.days.ago, bot_id: 42, hive_lbs: 22)
          Reading.create(created_at: 61.days.ago, bot_id: 43, hive_lbs: 23)
          @result = composition.composite_readings
        end

        it 'returns composites for 59 days ago' do
          expect(@result.map(&:timestamp))
            .to include(59.days.ago.utc.beginning_of_hour)
        end

        it 'does not return composites for 61 days ago' do
          expect(@result.map(&:timestamp))
            .not_to include(61.days.ago.beginning_of_hour)
        end
      end

      context 'daily composites' do
        let(:span) { :daily }

        before do
          Reading.create(created_at: 4.years.ago + 1.day,
                         bot_id: 42,
                         hive_lbs: 22)
          Reading.create(created_at: 4.years.ago - 1.day,
                         bot_id: 43,
                         hive_lbs: 23)
          @result = composition.composite_readings
        end

        it 'returns composites for up to 4 years ago' do
          expect(@result.map(&:timestamp))
            .to include((4.years.ago + 1.day).utc.strftime('%Y-%m-%d'))
        end

        it 'does not return composites for more than 4 years ago' do
          expect(@result.map(&:timestamp))
            .not_to include((4.years.ago - 1.day).utc.strftime('%Y-%m-%d'))
        end
      end
    end

    context 'composed columns' do
      before do
        Reading.create(created_at: 3.hours.ago,
                       bot_id: 42,
                       brood_temp: 10,
                       hive_lbs: 41)
        Reading.create(created_at: 3.hours.ago,
                       bot_id: 42,
                       brood_temp: 20,
                       hive_lbs: 43)
        @timestamp = 3.hours.ago.utc.strftime('%Y-%m-%d %H')
      end

      it 'returns the average hive_lbs' do
        expect(composition.hive_lbs[@timestamp]).to eq(42)
      end

      it 'returns the average brood_temp' do
        expect(composition.brood_temp[@timestamp]).to eq(15)
      end
    end
  end
end
