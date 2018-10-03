# frozen_string_literal: true

class Filters::Base
  # Override this method
  def filter_mail(mail)
    mail
  end
end
