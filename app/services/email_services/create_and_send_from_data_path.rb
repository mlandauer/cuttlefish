# frozen_string_literal: true

module EmailServices
  class CreateAndSendFromDataPath < ApplicationService
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
        email = Email.create!(
          to: to,
          data: File.read(data_path),
          app_id: app_id,
          ignore_deny_list: ignore_deny_list
        )
        EmailServices::Send.call(email: email)
        email
      end

      # Delete the temporary file now that we don't need it anymore
      File.delete(data_path)

      success!
      email
    end

    private

    attr_reader :to, :data_path, :app_id, :ignore_deny_list
  end
end
