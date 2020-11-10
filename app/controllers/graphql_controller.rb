# frozen_string_literal: true

class GraphqlController < ApplicationController
  skip_before_action :verify_authenticity_token

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_admin: current_admin
    }
    result = CuttlefishSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )
    render json: result
  # rubocop:disable Style/RescueStandardError
  rescue => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end
  # rubocop:enable Style/RescueStandardError

  private

  def current_admin
    @current_admin ||= (Admin.find(admin_id_from_request_header) if admin_id_from_request_header)
  end

  def jwt_token_from_request_header
    header = request.headers["HTTP_AUTHORIZATION"]
    return if header.nil?

    # Expect header to be in the following form with the token being a
    # json web token that has been signed by us
    # Authorization: Bearer <token>
    m = header.match(/^Bearer (.*)/)
    return if m.nil?

    m[1]
  end

  def admin_id_from_request_header
    jwt_token = jwt_token_from_request_header
    return if jwt_token.nil?

    payload, _header = JWT.decode(jwt_token, ENV["JWT_SECRET"], true, { algorithm: "HS512" })
    payload["admin_id"]
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    json = {
      error: { message: error.message, backtrace: error.backtrace },
      data: {}
    }
    render json: json, status: 500
  end
end
