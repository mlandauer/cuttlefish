class AppsController < ApplicationController
  after_action :verify_authorized, except: [:index, :show, :create, :edit, :update, :dkim]

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
      copy_graphql_errors(result.data.create_app, @app)
      render :new
    end
  end

  def destroy
    @app = App.find(params[:id])
    authorize @app
    flash[:notice] = "App #{@app.name} successfully removed"
    @app.destroy
    redirect_to apps_path
  end

  def edit
    result = api_query id: params[:id]
    @app = result.data.app
  end

  def update
    update_app = UpdateApp.call(
      current_admin: current_admin,
      id: params[:id],
      name: app_parameters['name'],
      open_tracking_enabled: app_parameters['open_tracking_enabled'],
      click_tracking_enabled: app_parameters['click_tracking_enabled'],
      custom_tracking_domain: app_parameters['custom_tracking_domain'],
      from_domain: app_parameters['from_domain']
    )

    @app = update_app.result
    if update_app.success?
      flash[:notice] = "App #{@app.name} successfully updated"
      if app_parameters.has_key?(:from_domain)
        redirect_to dkim_app_path(@app)
      else
        redirect_to @app
      end
    else
      if update_app.error.type == :permission
        raise NotAuthorizedError, "Permission error"
      end
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
