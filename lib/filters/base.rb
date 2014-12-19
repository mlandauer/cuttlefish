class Filters::Base
  attr_reader :delivery

  def initialize(delivery)
    @delivery = delivery
  end

  # Override this method
  def filter(content)
    filter_mail(Mail.new(content)).to_s
  end

  def filter_mail(mail)
    mail
  end
end
