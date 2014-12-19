class Filters::Base
  attr_reader :delivery
  
  def initialize(delivery)
    @delivery = delivery
  end

  # Override this method
  def filter(content)
    content
  end
end
