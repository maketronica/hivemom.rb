class Mother
  OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
  INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

  attr_reader :rack_request

  def call(env)
    @rack_request = Rack::Request.new(env)
    return OKAY if params.to_h.empty?
    if @rack_request.put?
      reading = Reading.create(params)
      return reading.valid? ? OKAY : INVALID
    else
      send_rack_response
    end
  end

  private

  def send_rack_response
    # TODO: give dev jekyll env it's own source of data
    # and then remove the Access-Control-Allow-Origin header
    response = Rack::Response.new
    response.body = [data]
    response['Access-Control-Allow-Origin'] = '*'
    response.status = 200
    response.finish
  end

  def data
    temp_data if params[:query][:metric] == 'temperatures'
  end

  def temp_data
    CSV.generate do |csv|
      csv << %w(probeid timestamp temperature)
      Reading.order(:created_at).each do |r|
        probeid = "HIVE_#{r.hive_id}_BOT"
        csv << [probeid, r.created_at, r.bot_temp]
        probeid = "HIVE_#{r.hive_id}_BROOD"
        csv << [probeid, r.created_at, r.brood_temp]
      end
    end
  end

  def params
    rack_request.params.with_indifferent_access
  end
end
