# frozen_string_literal: true

if Rails.env.development?
  GraphiQL::Rails.config.headers["Authorization"] = lambda do |_context|
    # GraphiQL will always make requests on behalf of the first admin
    Admin.first.api_key
  end
end
