class ApplicationService
  attr_reader :result

  # Give services a slightly more concise way of being called
  def self.call(params)
    object = new(params)
    object.instance_eval { |o| @result = call }
    object
  end

  def success!
    @success = true
  end

  def fail!
    @success = false
  end

  def success?
    @success
  end

  private
  attr_writer :result
end
