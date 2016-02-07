class Mother
  OKAY = ['200', { 'content-Type' => 'text/html' }, ['OKAY']].freeze
  INVALID = ['400', { 'content-Type' => 'text/html' }, ['INVALID']].freeze

  attr_reader :request

  def call(env)
    @request = Rack::Request.new(env)
    return OKAY if params.to_h.empty?
    if @request.post?
      reading = Reading.create(params)
      return reading.valid? ? OKAY : INVALID
    else
      return ['200', { 'content-Type' => 'text/html' }, data]
    end
  end

  private

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
    request.params.with_indifferent_access
  end
end
