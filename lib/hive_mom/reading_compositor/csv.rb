module HiveMom
  class ReadingCompositor
    class Csv
      attr_reader :compositor, :csv_compiler, :name, :file_constructor

      def initialize(name,
                     compositor,
                     csv_compiler = CsvCompilation,
                     file_constructor = File)
        @name = name
        @compositor = compositor
        @csv_compiler = csv_compiler
        @file_constructor = file_constructor
      end

      def write_to_file
        file_pointer = file_constructor.open("#{csv_folder}/#{filename}", 'w')
        file_pointer.write(csv_compilation.content)
      ensure
        file_pointer.try(:close)
      end

      def upload
        s3_object.put(body: csv_compilation.content)
      rescue Errno::ECONNRESET
        HiveMom.logger.info(self.class) do
          "Rescuing from connection reset on uplodad: #{filename}"\
          'Will try again later.'
        end
      end

      private

      def s3_object
        @s3_object ||= HiveMom.s3_bucket.object(filename)
      end

      def csv_folder
        HiveMom.config.csv_folder
      end

      def filename
        "#{name}_data.csv"
      end

      def csv_compilation
        @compiliation ||= csv_compiler.new(name)
      end
    end
  end
end
