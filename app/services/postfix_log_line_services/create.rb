# frozen_string_literal: true

module PostfixLogLineServices
  class Create < ApplicationService
    def initialize(line)
      super()
      @line = line
    end

    def call
      PostfixLogLine.transaction do
        log_line = create(line)
        # Check if an email needs to be deny listed
        add_to_deny_list(log_line.delivery) if log_line && log_line.status == "hard_bounce"
      end
    end

    def create(line)
      PostfixLogLine.create_from_line(line)
    end

    def add_to_deny_list(delivery)
      # It is possible for the team_id to be nil if it's a mail from the
      # cuttlefish "app" that is causing a hard bounce. For the time being
      # let's just ignore those mails and not try to add them to the deny
      # list because if we do they will cause an error
      # TODO: Fix this properly. What's here now is just a temporary
      # workaround
      return if delivery.app.team_id.nil?

      # We don't want to save duplicates
      return if DenyList.find_by(
        team_id: delivery.app.team_id,
        address: delivery.address
      )

      DenyList.create(
        team_id: delivery.app.team_id,
        address: delivery.address,
        caused_by_delivery: delivery
      )
    end

    private

    attr_reader :line
  end
end
