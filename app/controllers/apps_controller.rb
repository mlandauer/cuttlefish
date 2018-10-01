class AppsController < ApplicationController
  after_action :verify_authorized, except: [
    :index, :show, :create, :destroy, :edit, :update, :dkim
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
    authorize :app
  end

  def create
    # Using the form object to do type casting before we pass values
    # to the graphql api
    # TODO: Actually no need for strong parameters here as form object
    # constrains the parameters that are allowed
    @app = AppForm.new(app_parameters)

    result = api_query @app.attributes
    if result.data.create_app.app
      @app = result.data.create_app.app
      flash[:notice] = "App #{@app.name} successfully created"
      redirect_to app_url(@app.id)
    else
      copy_graphql_errors(result.data.create_app, @app, ['attributes'])
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
      copy_graphql_errors(result.data.remove_app, app, ['attributes'])

      flash[:alert] = app.errors.full_messages.join(', ')
      redirect_to edit_app_path(params[:id])
    end
  end

  def edit
    result = api_query id: params[:id]
    @app = result.data.app
  end

  def update
    @app = AppForm.new(app_parameters.merge(id: params[:id]))
    # Use the form object for type conversion but only copy across
    # attributes when they're present in app_parameters because the form
    # object doesn't currently support optional attributes
    attributes = Hash[app_parameters.to_h.map {|k, v|
      [k.to_s.camelize(:lower), @app.attributes[k.to_sym]]
    }]
    result = api_query id: params[:id], attributes: attributes
    if result.data.update_app.app
      @app = result.data.update_app.app
      flash[:notice] = "App #{@app.name} successfully updated"
      if app_parameters.has_key?(:from_domain)
        redirect_to dkim_app_path(@app.id)
      else
        redirect_to app_path(@app.id)
      end
    else
      copy_graphql_errors(result.data.update_app, @app, ['attributes'])
      render :edit
    end
  end

  # New password and lock password are currently not linked to from anywhere

  def new_password
    app = App.find(params[:id])
    app.new_password!
    redirect_to app
  end

  def lock_password
    app = App.find(params[:id])
    app.update_attribute(:smtp_password_locked, true)
    redirect_to app
  end

  def dkim
    result = api_query id: params[:id]
    @app = result.data.app
    @provider = params[:provider]
  end

  def toggle_dkim
    app = App.find(params[:id])
    authorize app
    app.update_attribute(:dkim_enabled, !app.dkim_enabled)
    redirect_to app
  end

  def upgrade_dkim
    app = App.find(params[:id])
    authorize app
    app.update_attribute(:legacy_dkim_selector, false)
    flash[:notice] = "App #{app.name} successfully upgraded to use the new DNS settings"
    redirect_to app
  end

  private

  def app_parameters
    params.require(:app).permit(:name, :url, :custom_tracking_domain, :open_tracking_enabled,
      :click_tracking_enabled, :from_domain)
  end
end
