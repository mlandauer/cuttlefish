# frozen_string_literal: true

class AppsController < ApplicationController
  after_action :verify_authorized, except: %i[
    index show new create destroy edit update dkim toggle_dkim upgrade_dkim
  ]

  def index
    result = api_query
    @apps = result.data.apps
  end

  def show
    result = api_query id: params[:id]
    @app = result.data.app
  end

  def new
    @app = AppForm.new
  end

  def create
    # TODO: Actually no need for strong parameters here as form object
    # constrains the parameters that are allowed
    result = api_query attributes: coerced_app_params
    if result.data.create_app.app
      @app = result.data.create_app.app
      flash[:notice] = "App #{@app.name} successfully created"
      redirect_to app_url(@app.id)
    else
      @app = AppForm.new(app_parameters)
      copy_graphql_errors(result.data.create_app, @app, ["attributes"])
      render :new
    end
  end

  def destroy
    result = api_query id: params[:id]

    if result.data.remove_app.errors.empty?
      @app = result.data.remove_app.app
      flash[:notice] = "App #{@app.name} successfully removed"
      redirect_to apps_path
    else
      # Convert errors to a single string using a form object
      app = AppForm.new
      copy_graphql_errors(result.data.remove_app, app, ["attributes"])

      flash[:alert] = app.errors.full_messages.join(", ")
      redirect_to edit_app_path(params[:id])
    end
  end

  def edit
    result = api_query id: params[:id]
    @app = result.data.app
  end

  def update
    result = api_query id: params[:id],
                       attributes: coerced_app_params
    if result.data.update_app.app
      @app = result.data.update_app.app
      flash[:notice] = "App #{@app.name} successfully updated"
      if app_parameters.key?(:from_domain)
        redirect_to dkim_app_path(@app.id)
      else
        redirect_to app_path(@app.id)
      end
    else
      @app = AppForm.new(app_parameters.merge(id: params[:id]))
      copy_graphql_errors(result.data.update_app, @app, ["attributes"])
      render :edit
    end
  end

  def dkim
    result = api_query id: params[:id]
    @app = result.data.app
    @provider = params[:provider]
  end

  def toggle_dkim
    # First do a query
    result = api_query :toggle_dkim_query, id: params[:id]
    dkim_enabled = result.data.app.dkim_enabled
    # Then write the changes using the api
    result = api_query :update,
                       id: params[:id],
                       attributes: { dkimEnabled: !dkim_enabled }
    if result.data.update_app.app.nil?
      # Convert errors to a single string using a form object
      app = AppForm.new
      copy_graphql_errors(result.data.update_app, app, ["attributes"])

      flash[:alert] = app.errors.full_messages.join(", ")
    end
    redirect_to app_url(params[:id])
  end

  def upgrade_dkim
    result = api_query id: params[:id]
    app = result.data.upgrade_app_dkim.app
    flash[:notice] =
      "App #{app.name} successfully upgraded to use the new DNS settings"
    redirect_to app_url(app.id)
  end

  private

  def coerced_app_params
    result = coerce_params(app_parameters, AppForm)
    # Doing an extra bit of type conversion here
    result["webhookUrl"] = nil if result["webhookUrl"].blank?
    result
  end

  def app_parameters
    params.require(:app).permit(
      :name, :url, :custom_tracking_domain, :open_tracking_enabled,
      :click_tracking_enabled, :from_domain, :webhook_url
    )
  end
end
