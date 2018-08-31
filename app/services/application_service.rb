class ApplicationService
  # Give services a slightly more concise way of being called
  def self.call(params)
    new(params).call
  end
end
