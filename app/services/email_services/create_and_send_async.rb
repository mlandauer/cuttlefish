# frozen_string_literal: true

module EmailServices
  class CreateAndSendAsync < ApplicationService
    def initialize(to:, data:, app_id:, ignore_deny_list:)
      @to = to
      @data = data
      @app_id = app_id
      @ignore_deny_list = ignore_deny_list
    end

    def call
      email = Email.create!(
        to: to,
        data: data,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list
      )

      SendEmailWorker.perform_async(email.id)

      success!
      email
    end

    private

    attr_reader :to, :data, :app_id, :ignore_deny_list
  end
end
