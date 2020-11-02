# frozen_string_literal: true

class GraphqlController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :authenticate_with_api_key!

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

  # def authenticate_with_api_key!
  #   render(plain: 'API key is not valid', status: 401) if current_admin.nil?
  # end

  def current_admin
    @current_admin ||=
      Admin.find_by(api_key: request.headers["HTTP_AUTHORIZATION"])
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
