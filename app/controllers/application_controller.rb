# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_admin!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(_resource)
    dash_path
  end

  force_ssl if: proc { force_ssl? }

  # Either use api_query id: 2 or api_query :other_name, id: 2
  def api_query(params1 = {}, params2 = nil)
    if params2
      file_prefix = params1.to_s
      variables = params2
    else
      file_prefix = action_name
      variables = params1
    end
    query_name = "#{controller_name}_#{file_prefix}".upcase
    query = Api::Queries.const_get(query_name)

    Api.query(
      query,
      variables: variables,
      current_admin: current_admin
    )
  end

  # Take graphql object with errors and attach them to the given form object
  def copy_graphql_errors(graphql, form, root_path)
    graphql.errors.each do |error|
      if error.path[0..-2] == root_path
        form.errors.add(
          error.path[-1].underscore,
          error.type.downcase.to_sym,
          message: error.message
        )
      elsif error.path == []
        form.errors.add(
          :base,
          error.type.downcase.to_sym,
          message: error.message
        )
      end
    end
  end

  def coerce_params(params, form_klass)
    # Use the form object for type coercion but only copy across
    # attributes when they're present in params because the form
    # object always returns all the defined attributes even if they
    # haven't been set
    form = form_klass.new(params)
    t = params.to_h.map do |k, _v|
      [k.to_s.camelize(:lower), form.attributes[k.to_sym]]
    end
    Hash[t]
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # Don't use SSL for the TrackingController and in development
  def force_ssl?
    controller_name != "tracking" &&
      !Rails.env.development? &&
      !Rails.configuration.disable_ssl
  end

  def pundit_user
    current_admin
  end
end
