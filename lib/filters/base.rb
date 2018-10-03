# frozen_string_literal: true

module Filters
  class Base
    # Override this method
    def filter_mail(mail)
      mail
    end
  end
end
