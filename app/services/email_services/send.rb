# frozen_string_literal: true

module EmailServices
  class Send < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      success!
      email.deliveries.each { |delivery| send(delivery) }
    end

    private

    def send(delivery)
      OutgoingDelivery.new(delivery).send
    end

    attr_reader :email
  end
end
