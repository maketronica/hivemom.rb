module HiveMom
  class ReadingCompositor
    describe CsvCompilation do
      let(:composite_name) { :instant }
      let(:compilation) { CsvCompilation.new(composite_name) }

      it 'instantiates' do
        expect(compilation).to be_a(CsvCompilation)
      end

      describe '#content' do
        it 'has a header' do
          header_regex = /^probeid,timestamp/
          expect(compilation.content.lines.first).to match(header_regex)
        end

        it 'has readings' do
          reading = readings(:recent_1)
          matcher = "HIVE_#{reading.hive_id},#{reading.created_at.utc}"
          expect(compilation.content).to match(/#{matcher}/)
        end
      end
    end
  end
end
