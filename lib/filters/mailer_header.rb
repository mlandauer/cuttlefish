# frozen_string_literal: true

module Filters
  class MailerHeader < Filters::Base
    attr_accessor :version

    def initialize(version:)
      @version = version
    end

    def filter_mail(mail)
      mail.header["X-Mailer"] = "Cuttlefish #{version}"
      mail
    end
  end
end
