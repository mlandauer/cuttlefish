# frozen_string_literal: true

module DenyListsHelper
  def canonical_deny_lists_path(app:, dsn:)
    if app
      app_deny_lists_path(app.id, dsn: dsn)
    else
      deny_lists_path(dsn: dsn)
    end
  end
end
