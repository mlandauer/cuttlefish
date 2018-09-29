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
    destroy = App::Destroy.(current_admin: current_admin,id: params[:id])
    if destroy.success?
      @app = destroy.result
      flash[:notice] = "App #{@app.name} successfully removed"
    else
      flash[:alert] = destroy.error
    end
    redirect_to apps_path
  end

  def edit
    result = api_query id: params[:id]
    @app = result.data.app
  end

  def update
    @app = AppForm.new(app_parameters.merge(id: params[:id]))
    result = api_query @app.attributes.merge(id: params[:id])
    if result.data.update_app.app
      @app = result.data.update_app.app
      flash[:notice] = "App #{@app.name} successfully updated"
      if app_parameters.has_key?(:from_domain)
        redirect_to dkim_app_path(@app)
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
