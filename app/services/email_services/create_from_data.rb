# frozen_string_literal: true

module EmailServices
  class CreateFromData < ApplicationService
    def initialize(to:, data_path:, app_id:, ignore_deny_list:)
      super()
      @to = to
      @data_path = data_path
      @app_id = app_id
      @ignore_deny_list = ignore_deny_list
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
      Email.create!(
        to: to,
        data: File.read(data_path),
        app_id: app_id,
        ignore_deny_list: ignore_deny_list
      )
    end

    def send(email)
      EmailServices::Send.call(email: email)
    end

    def cleanup
      # Delete the temporary file now that we don't need it anymore
      File.delete(data_path)
    end

    private

    attr_reader :to, :data_path, :app_id, :ignore_deny_list
  end
end
