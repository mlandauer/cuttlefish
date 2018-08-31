class ApplicationService
  attr_reader :result

  # Give services a slightly more concise way of being called
  def self.call(params)
    object = new(params)
    object.instance_eval { |o| @result = call }
    object
  end

  private
  attr_writer :result
end
