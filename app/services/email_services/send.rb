# frozen_string_literal: true

module EmailServices
  class Send < ApplicationService
    def initialize(email:)
      super()
      @email = email
    end

    def call
      success!
      email.deliveries.each { |delivery| send(delivery) }
    end

    private

    def send(delivery)
      return unless delivery.send?

      # TODO: Replace use of Net::SMTP with deliver! as part of mail gem
      smtp = Net::SMTP.new(
        Rails.configuration.postfix_smtp_host,
        Rails.configuration.postfix_smtp_port
      )
      smtp.disable_ssl
      smtp.start do |smtp|
        response = smtp.send_message(
          Filters::Master.new(delivery: delivery).filter(delivery.data),
          delivery.return_path,
          [delivery.to]
        )
        delivery.update(
          open_tracked: delivery.open_tracking_enabled?,
          postfix_queue_id:
            extract_postfix_queue_id_from_smtp_message(response.message),
          sent: true
        )
      end
    end

    # When a message is sent via the Postfix MTA it returns the queue id
    # in the SMTP message. Extract this
    def extract_postfix_queue_id_from_smtp_message(message)
      m = message.match(/250 2.0.0 Ok: queued as (\w+)/)
      m[1] if m
    end

    attr_reader :email
  end
end
