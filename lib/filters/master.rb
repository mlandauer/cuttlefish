# frozen_string_literal: true

module Filters
  class Master < Filters::Base
    attr_reader :delivery

    def initialize(delivery:)
      @delivery = delivery
    end

    def filter(content)
      filter_mail(::Mail.new(content)).to_s
    end

    def filter_mail(mail)
      filter1 = Filters::AddOpenTracking.new(
        delivery_id: delivery.id,
        enabled: delivery.open_tracking_enabled?,
        tracking_domain: delivery.tracking_domain,
        tracking_protocol: delivery.tracking_protocol
      )
      filter2 = Filters::ClickTracking.new(
        delivery_id: delivery.id,
        enabled: delivery.click_tracking_enabled?,
        tracking_domain: delivery.tracking_domain,
        tracking_protocol: delivery.tracking_protocol
      )
      filter3 = Filters::InlineCss.new
      filter4 = Filters::MailerHeader.new(version: APP_VERSION)
      filter5 = Filters::Dkim.new(
        enabled: delivery.app.dkim_enabled,
        dkim_dns: DkimDns.new(
          domain: delivery.app.from_domain,
          private_key: delivery.app.dkim_private_key,
          selector: delivery.app.dkim_selector
        ),
        cuttlefish_enabled: App.cuttlefish.dkim_enabled,
        cuttlefish_dkim_dns: DkimDns.new(
          domain: App.cuttlefish.from_domain,
          private_key: App.cuttlefish.dkim_private_key,
          selector: App.cuttlefish.dkim_selector
        ),
        sender_email: Rails.configuration.cuttlefish_sender_email
      )

      filtered1 = filter1.filter_mail(mail)
      filtered2 = filter2.filter_mail(filtered1)
      filtered3 = filter3.filter_mail(filtered2)
      filtered4 = filter4.filter_mail(filtered3)
      # DKIM filter needs to always be the last one
      filter5.filter_mail(filtered4)
    end
  end
end
