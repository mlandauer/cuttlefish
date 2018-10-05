# frozen_string_literal: true

module Filters
  class Dkim < Filters::Base
    attr_accessor :dkim_dns, :sender_email, :enabled,
                  :cuttlefish_enabled, :cuttlefish_dkim_dns

    def initialize(enabled:, dkim_dns:, cuttlefish_enabled:,
                   cuttlefish_dkim_dns:, sender_email:)
      @enabled = enabled
      @dkim_dns = dkim_dns
      @cuttlefish_enabled = cuttlefish_enabled
      @cuttlefish_dkim_dns = cuttlefish_dkim_dns
      @sender_email = sender_email
    end

    def filter_mail(mail)
      unless in_correct_domain?(mail, dkim_dns.domain) && enabled
        mail.sender = sender_email
      end

      mail = sign(mail, enabled, dkim_dns)
      sign(mail, cuttlefish_enabled, cuttlefish_dkim_dns)
    end

    # DKIM sign the email if it's coming from the correct domain
    def sign(mail, enabled, dkim_dns)
      if in_correct_domain?(mail, dkim_dns.domain) && enabled
        dkim_dns.sign_mail(mail)
      else
        mail
      end
    end

    def in_correct_domain?(mail, domain)
      (mail.sender || mail.from.first).split("@")[1] == domain
    end
  end
end
