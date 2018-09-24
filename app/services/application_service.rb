class ApplicationService
  attr_reader :result

  class Failure < StandardError; end

  # Give services a slightly more concise way of being called
  def self.call(params)
    object = new(params)
    object.instance_eval do |o|
      begin
        @result = call
        @success = true
        result
      rescue Failure => e
        @success = false
        @message = e.message
      end
    end
    object
  end

  def call
    raise "You need to add a call method on a class inheriting from ApplicationService"
  end

  def success?
    @success
  end

  attr_reader :message

  private
  attr_writer :result
end
