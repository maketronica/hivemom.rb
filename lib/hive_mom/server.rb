module HiveMom
  class Server
    OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
    INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

    def call(env)
      rack_request = Rack::Request.new(env)
      log_request(rack_request)
      params = rack_request.params.with_indifferent_access
      return OKAY if params.to_h.empty?
      reading = create_reading(params)
      return INVALID unless reading.valid?
      OKAY
    end

    private

    def log_request(req)
      msg = "Received: #{req.request_method} from #{req.ip}, "\
            "Length: #{req.content_length}"
      HiveMom.logger.info(self.class) { msg }
    end

    def create_reading(params)
      Reading.create(params.merge(sampled_at: Time.now, composite: 'instant'))
    end
  end
end
