# frozen_string_literal: true

# For Sidekiq
class ParseHeadersCreateEmailWorker
  include Sidekiq::Worker

  # Can't use keyword arguments in sidekiq
  # See https://github.com/mperham/sidekiq/issues/2372
  def perform(to, data_path, app_id)
    EmailServices::ParseHeadersCreate.call(
      to: to,
      data: File.read(data_path, encoding: "ASCII-8BIT"),
      app_id: app_id
    )
    # Cleanup the temporary file
    File.delete(data_path)
  end
end
