# frozen_string_literal: true

class OutgoingDelivery
  attr_reader :delivery

  def initialize(delivery)
    @delivery = delivery
  end

  def send
    if delivery.send?
      # TODO Replace use of Net::SMTP with deliver! as part of mail gem
      Net::SMTP.start(Rails.configuration.postfix_smtp_host, Rails.configuration.postfix_smtp_port) do |smtp|
        response = smtp.send_message(Filters::Master.new(delivery).filter(delivery.data), delivery.return_path, [delivery.to])
        delivery.update_attributes(
          postfix_queue_id: OutgoingDelivery.extract_postfix_queue_id_from_smtp_message(response.message),
          sent: true)
      end
    end
  end

  # When a message is sent via the Postfix MTA it returns the queue id
  # in the SMTP message. Extract this
  def self.extract_postfix_queue_id_from_smtp_message(message)
    m = message.match(/250 2.0.0 Ok: queued as (\w+)/)
    m[1] if m
  end
end
