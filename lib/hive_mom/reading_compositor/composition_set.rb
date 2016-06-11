module HiveMom
  class ReadingCompositor
    class CompositionSet
      RESCUE_WAIT_BASE_TIME = 2
      attr_reader :name, :compositor, :previous_attempt_count,
                  :reading_constructor, :composition_constructor

      def initialize(name,
                     compositor,
                     reading_constructor = Reading,
                     composition_constructor = Composition)
        @name = name
        @compositor = compositor
        @reading_constructor = reading_constructor
        @composition_constructor = composition_constructor
        @previous_attempt_count = 0
      end

      def update
        return if name.to_sym == :instant
        begin
          reading_constructor.pluck(:hive_id).uniq.each do |hive_id|
            composition_constructor.new(hive_id, self).update
            reset_previous_attempt_count
          end
        rescue ActiveRecord::StatementInvalid => e
          process_rescued_error(e)
        end
      end

      private

      def reset_previous_attempt_count
        @previous_attempt_count = 0
      end

      def process_rescued_error(e)
        raise e unless e.message =~ /SQLite3::BusyException/
        HiveMom.logger.error(self.class) do
          "Compositor Rescuing from #{e.class} : #{e.message}\n"\
          "Compositor Waiting for #{rescue_wait_time} seconds."
        end
        sleep rescue_wait_time
        increment_previous_attempt_count
      end

      def rescue_wait_time
        RESCUE_WAIT_BASE_TIME**previous_attempt_count
      end

      def increment_previous_attempt_count
        @previous_attempt_count += 1
      end
    end
  end
end
