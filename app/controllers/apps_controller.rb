class AppsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @apps = policy_scope(App).order(:name)
  end

  def show
    @app = App.find(params[:id])
    authorize @app
  end

  def new
    @app = App.new
    authorize @app
  end

  def create
    @app = current_admin.team.apps.build(app_parameters)
    authorize @app
    if @app.save
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
    @app = App.find(params[:id])
    authorize @app
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
    @app = App.find(params[:id])
    @dkim_dns = DkimDns.new(
      domain: @app.from_domain,
      private_key: @app.dkim_private_key,
      selector: @app.dkim_selector
    )
    authorize @app
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
