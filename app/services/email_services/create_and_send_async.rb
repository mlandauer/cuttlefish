# frozen_string_literal: true

module EmailServices
  class CreateAndSendAsync < ApplicationService
    def initialize(to:, data:, app_id:, ignore_deny_list:)
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
      file = Tempfile.new("email")
      file.write(data)
      file.close
      data_path = file.path

      # Read the data back in from the temporary file
      data2 = File.open(data_path) do |f|
        f.read
      end

      email = Email.create!(
        to: to,
        data: data2,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list
      )

      # Delete the temporary file now that we don't need it anymore
      File.delete(data_path)

      SendEmailWorker.perform_async(email.id)

      success!
      email
    end

    private

    attr_reader :to, :data, :app_id, :ignore_deny_list
  end
end
