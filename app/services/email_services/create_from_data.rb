# frozen_string_literal: true

module EmailServices
  class CreateFromData < ApplicationService
    def initialize(to:, data_path:, app_id:, ignore_deny_list:, meta_values:)
      super()
      @to = to
      @data_path = data_path
      @app_id = app_id
      @ignore_deny_list = ignore_deny_list
      @meta_values = meta_values
    end

    # Note that this service depends on having access to the same filesystem as
    # the worker processes have access to. Currently, that's fine because we're
    # running everything on a single machine but that assumption might not be
    # true in the future
    def call
      email = ActiveRecord::Base.transaction do
        email = create
        send(email)
        email
      end
      cleanup
      success!
      email
    end

    def create
      email = Email.create!(
        to: to,
        data: File.read(data_path),
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

    def cleanup
      # Delete the temporary file now that we don't need it anymore
      File.delete(data_path)
    end

    private

    attr_reader :to, :data_path, :app_id, :ignore_deny_list, :meta_values
  end
end
