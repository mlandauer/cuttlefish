# frozen_string_literal: true

module Filters
  class MailerHeader < Filters::Base
    attr_accessor :version

    def initialize(options)
      @version = options[:version]
    end

    def filter_mail(mail)
      mail.header["X-Mailer"] = "Cuttlefish #{version}"
      mail
    end
  end
end
