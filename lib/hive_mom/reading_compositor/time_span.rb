module HiveMom
  class ReadingCompositor
    class TimeSpan
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def start_for(datetime)
        Time.at((datetime.to_i / length) * length)
      end

      def length
        @length ||= num_of_span_units.to_f.send(span_unit_name)
      end

      private

      def num_of_span_units
        decompiled_name[1]
      end

      def span_unit_name
        decompiled_name[2]
      end

      def decompiled_name
        @decompiled_name ||= /^([[:digit:]\.]+)_([[:alpha:]]+)$/.match(name)
      end
    end
  end
end
