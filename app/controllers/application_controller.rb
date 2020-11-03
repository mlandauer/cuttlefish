# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # TODO: Also make sure we get redirected back to the original url
  rescue_from Pundit::NotAuthorizedError do |_exception|
    # TODO: In an ideal world we would differentiate between a person not
    # being logged in at all and so not being able to access a resource and
    # a person being logged but not having the permissions to access the
    # specific resource. Then, we would only redirect if the user was not
    # logged in. Otherwise we would just raise another error
    flash[:alert] = "You need to sign in or sign up before continuing."
    redirect_to new_admin_session_url
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
    # TODO: Use controller_path instead of controller_name
    # so that module name gets included
    query = Api::Queries.get(controller_name, file_prefix)

    Api.query(
      query,
      variables: variables,
      jwt_token: session[:jwt_token]
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

  # Don't use SSL for the TrackingController and in development
  def force_ssl?
    controller_name != "tracking" &&
      !Rails.env.development? &&
      !Rails.configuration.disable_ssl
  end
end
