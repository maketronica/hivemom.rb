module HiveMom
  class ReadingComposition
    UNCOMPOSED_COLUMNS = %w(id hive_id bot_id updated_at).freeze

    attr_reader :span

    def initialize(span)
      @span = span
    end

    def composite_readings
      if span == :minutely
        readings
      else
        timestamps.map { |t| CompositeReading.new(t, self) }
      end
    end

    def method_missing(method_name, *args, &block)
      if composed_columns.include?(method_name.to_s)
        construct_and_call(method_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      composed_columns.include?(method_name.to_s) || super
    end

    private

    def timestamps
      reading_groups.average(:id).keys
    end

    def construct_and_call(method_name)
      self.class.send(:define_method, method_name) do
        reading_groups.average(method_name)
      end
      send(method_name)
    end

    def reading_groups
      readings.group(group_clause)
    end

    def readings
      Reading.where(['created_at > ?', max_age])
    end

    def group_clause
      case span
      when :hourly then %(strftime('%Y-%m-%d %H', created_at))
      when :daily then %(strftime('%Y-%m-%d', created_at))
      end
    end

    def max_age
      case span
      when :minutely then 24.hours.ago
      when :hourly then 60.days.ago
      when :daily then 4.years.ago
      end
    end

    def composed_columns
      Reading.column_names - UNCOMPOSED_COLUMNS
    end

    class CompositeReading
      attr_reader :timestamp, :composition

      def initialize(timestamp, composition)
        @timestamp = timestamp
        @composition = composition
      end

      def method_missing(method_name, *args, &block)
        if composition.respond_to?(method_name)
          konstruct_and_call(method_name)
        else
          super
        end
      end

      private

      def konstruct_and_call(method_name)
        self.class.send(:define_method, method_name) do
          composition.send(method_name)[timestamp]
        end
        send(method_name)
      end
    end
  end
end
