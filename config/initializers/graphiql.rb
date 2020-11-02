# frozen_string_literal: true

if Rails.env.development?
  GraphiQL::Rails.config.headers["Authorization"] = lambda do |context|
    # GraphiQL will make requests on behalf of the currently logged in admin
    "Bearer #{context.session[:jwt_token]}"
  end
end
