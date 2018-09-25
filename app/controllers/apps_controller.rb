class AppsController < ApplicationController
  after_action :verify_authorized, except: [:index, :show, :create, :edit, :dkim]

  def index
    result = api_query2
    @apps = result.data.apps
  end

  def show
    result = api_query2 id: params[:id]
    @app = result.data.app
  end

  def new
    @app = AppForm.new
    authorize :app
  end

  def create
    create_app = CreateApp.call(
      current_admin: current_admin,
      name: params['app']['name'],
      open_tracking_enabled: params['app']['open_tracking_enabled'],
      click_tracking_enabled: params['app']['click_tracking_enabled'],
      custom_tracking_domain: params['app']['custom_tracking_domain']
    )
    @app = create_app.result
    if create_app.success?
      flash[:notice] = "App #{@app.name} successfully created"
      redirect_to @app
    else
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
    result = api_query2 id: params[:id]
    @app = result.data.app
  end

  def update
    @app = App.find(params[:id])
    authorize @app
    if @app.update_attributes(app_parameters)
      flash[:notice] = "App #{@app.name} successfully updated"
      if app_parameters.has_key?(:from_domain)
        redirect_to dkim_app_path(@app)
      else
        redirect_to @app
      end
    else
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
    result = api_query2 id: params[:id]
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
