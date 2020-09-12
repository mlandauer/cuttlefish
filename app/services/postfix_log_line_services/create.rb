# frozen_string_literal: true

module PostfixLogLineServices
  class Create < ApplicationService
    def initialize(line)
      super()
      @line = line
    end

    def call
      log_line = PostfixLogLine.transaction do
        log_line = create(line)
        return if log_line.nil?

        # Check if an email needs to be deny listed
        add_to_deny_list(log_line.delivery) if log_line.status == "hard_bounce"
        log_line
      end
      # Now send webhook if required
      return if log_line.delivery.app.webhook_url.nil?

      PostDeliveryEventWorker.perform_async(
        log_line.delivery.app.webhook_url,
        log_line.delivery.app.webhook_key,
        log_line.id
      )
    end

    def create(line)
      # TODO: Inline the business logic currently in the model into the service
      PostfixLogLine.create_from_line(line)
    end

    def add_to_deny_list(delivery)
      # We don't want to save duplicates
      return if DenyList.find_by(
        app: delivery.app,
        address: delivery.address
      )

      DenyList.create(
        app: delivery.app,
        address: delivery.address,
        caused_by_delivery: delivery
      )
    end

    private

    attr_reader :line
  end
end
