# frozen_string_literal: true

module EmailServices
  class Send < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      success!
      email.deliveries.each do |delivery|
        OutgoingDelivery.new(delivery).send
      end
    end

    private

    attr_reader :email
  end
end
