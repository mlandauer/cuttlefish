# frozen_string_literal: true

module EmailServices
  class CreateAndSendAsync < ApplicationService
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

      CreateAndSendEmailWorker.perform_async(to, file.path, app_id, ignore_deny_list)

      success!
    end

    private

    attr_reader :to, :data, :app_id, :ignore_deny_list
  end
end
