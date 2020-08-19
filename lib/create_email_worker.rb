# frozen_string_literal: true

# For Sidekiq
class CreateEmailWorker
  include Sidekiq::Worker

  # Can't use keyword arguments in sidekiq
  # See https://github.com/mperham/sidekiq/issues/2372
  def perform(to, data_path, app_id, ignore_deny_list, meta_values)
    EmailServices::CreateFromData.call(
      to: to,
      data_path: data_path,
      app_id: app_id,
      ignore_deny_list: ignore_deny_list,
      meta_values: meta_values
    )
  end
end
