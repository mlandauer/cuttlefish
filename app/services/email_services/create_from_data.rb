# frozen_string_literal: true

module EmailServices
  class CreateFromData < ApplicationService
    def initialize(to:, data:, app_id:, ignore_deny_list:, meta_values:)
      super()
      @to = to
      @data = data
      @app_id = app_id
      @ignore_deny_list = ignore_deny_list
      @meta_values = meta_values
    end

    # Note that this service depends on having access to the same filesystem as
    # the worker processes have access to. Currently, that's fine because we're
    # running everything on a single machine but that assumption might not be
    # true in the future
    def call
      ActiveRecord::Base.transaction do
        email = create
        send(email)

        success!
        email
      end
    end

    def create
      email = Email.create!(
        to: to,
        data: data,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list
      )
      meta_values.each do |key, value|
        email.meta_values.create!(key: key, value: value)
      end
      email
    end

    def send(email)
      EmailServices::Send.call(email: email)
    end

    private

    attr_reader :to, :data, :app_id, :ignore_deny_list, :meta_values
  end
end
