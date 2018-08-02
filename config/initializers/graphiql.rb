if Rails.env.development?
  GraphiQL::Rails.config.headers['Authorization'] = -> (_context) {
    # GraphiQL will always make requests on behalf of the first admin
    Admin.first.api_key
  }
end
