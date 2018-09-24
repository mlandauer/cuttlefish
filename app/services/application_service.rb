class ApplicationService
  attr_reader :result

  # Give services a slightly more concise way of being called
  def self.call(params)
    object = new(params)
    object.instance_eval { |o| @result = call }
    object
  end

  def call
    raise "You need to add a call method on a class inheriting from ApplicationService"
  end

  def success!
    @success = true
  end

  def fail!(message)
    @success = false
    @message = message
    nil
  end

  def success?
    @success
  end

  attr_reader :message

  private
  attr_writer :result
end
