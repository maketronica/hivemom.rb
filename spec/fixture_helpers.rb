module FixtureHelpers
  def method_missing(method_name, *args, &block)
    if fixture_names.include?(method_name)
      method_name
        .to_s
        .singularize
        .titleize
        .constantize
        .find(fixture_id(args[0]))
    else
      super
    end
  end

  def fixture_id(label)
    ActiveRecord::FixtureSet.identify(label)
  end

  def fixture_names
    Dir["#{File.expand_path('../fixtures', __FILE__)}/*.yml"]
      .map { |filename| filename.match(%r{\/([^\/]+)\.yml})[1].to_sym }
  end
end
