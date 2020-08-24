# frozen_string_literal: true

module PostfixLogLineServices
  class Create < ApplicationService
    def initialize(line)
      super()
      @line = line
    end

    def call
      PostfixLogLine.transaction do
        log_line = PostfixLogLine.create_from_line(line)
        # Check if an email needs to be deny listed
        if log_line && log_line.status == "hard_bounce"
          # We don't want to save duplicates
          if DenyList.find_by(
            team_id: log_line.delivery.app.team_id,
            address: log_line.delivery.address
          ).nil?
            # It is possible for the team_id to be nil if it's a mail from the
            # cuttlefish "app" that is causing a hard bounce. For the time being
            # let's just ignore those mails and not try to add them to the deny
            # list because if we do they will cause an error
            # TODO: Fix this properly. What's here now is just a temporary
            # workaround
            if log_line.delivery.app.team_id
              DenyList.create(
                team_id: log_line.delivery.app.team_id,
                address: log_line.delivery.address,
                caused_by_delivery: log_line.delivery
              )
            end
          end
        end
      end
    end

    private

    attr_reader :line
  end
end
