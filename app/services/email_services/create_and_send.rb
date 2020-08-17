# frozen_string_literal: true

module EmailServices
  class CreateAndSend < ApplicationService
    def initialize(to:, data:, app_id:, ignore_deny_list:)
      super()
      @to = to
      @data = data
      @app_id = app_id
      @ignore_deny_list = ignore_deny_list
    end

    # Note that this service depends on having access to the same filesystem as
    # the worker processes have access to. Currently, that's fine because we're
    # running everything on a single machine but that assumption might not be
    # true in the future
    def call
      # Store content of email in a temporary file
      file = Tempfile.new("cuttlefish")
      file.write(data)
      file.close

      email = EmailServices::CreateAndSendFromDataPath.new(
        to: to,
        data_path: file.path,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list
      ).call

      success!
      email
    end

    private

    attr_reader :to, :data, :app_id, :ignore_deny_list
  end
end
