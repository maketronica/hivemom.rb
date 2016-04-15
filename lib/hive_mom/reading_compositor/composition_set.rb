module HiveMom
  class ReadingCompositor
    class CompositionSet
      RESCUE_WAIT_BASE_TIME = 2
      attr_reader :name, :compositor, :previous_attempt_count

      def initialize(name, compositor)
        @name = name
        @compositor = compositor
        @previous_attempt_count = 0
      end

      def update
        return if name.to_sym == :instant
        Reading.pluck(:hive_id).uniq.each do |hive_id|
          begin
            Composition.new(hive_id, self).update
          rescue ActiveRecord::StatementInvalid => e
            process_rescued_error(e)
          end
        end
      end

      private

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
