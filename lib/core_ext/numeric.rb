class Numeric
  def months
    ActiveSupport::Duration.new(self * 30.days, [[:months, self]])
  end
  alias month months

  def years
    ActiveSupport::Duration.new(self * 365.25.days.to_i, [[:years, self]])
  end
  alias year years
end
