# frozen_string_literal: true

class ApplicationService
  attr_reader :result

  # Give services a slightly more concise way of being called
  def self.call(params)
    object = new(params)
    object.instance_eval { @result = call }
    object
  end

  def call
    raise "You need to add a call method on a class inheriting " \
          "from ApplicationService"
  end

  def success!
    @success = true
  end

  # error can be a string or an object
  def fail!
    @success = false
    nil
  end

  def success?
    @success
  end

  private

  attr_writer :result
end
