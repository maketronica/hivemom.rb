module HiveMom
  class ReadingCompositor
    describe Csv do
      let(:name) { 'hour' }
      let(:content) { 'this,is,some,content' }
      let(:file_pointer) { double('file_pointer', write: true) }
      let(:file_constructor) { double('File', open: file_pointer) }
      let(:csv_compilation) { double('csv_compilation', content: content) }
      let(:csv_compiler) { double('CsvCompilation', new: csv_compilation) }
      let(:s3_object) { double('s3_object', put: true) }
      let(:s3_bucket) { double('s3_bucket', object: s3_object) }
      let(:compositor) { double('compositor', s3_bucket: s3_bucket) }
      let(:csv) { Csv.new(name, compositor, csv_compiler, file_constructor) }

      describe '#upload' do
        it 'puts content to s3 object' do
          expect(s3_object).to receive(:put).with(body: content)
          csv.upload
        end
      end

      describe '#write_to_file' do
        it 'writes to the file' do
          expect(file_pointer).to receive(:write).with(content)
          csv.write_to_file
        end

        it 'closes the pointer' do
          expect(file_pointer).to receive(:close)
          csv.write_to_file
        end

        context 'when the write fails' do
          before do
            allow(file_pointer).to receive(:write).and_raise(RuntimeError)
          end

          it 'still closes the pointer' do
            expect(file_pointer).to receive(:close)
            expect { csv.write_to_file }.to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
