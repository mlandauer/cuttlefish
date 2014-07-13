class AppsController < ApplicationController
  def index
    @apps = App.all
  end

  def show
    @app = App.find(params[:id])
  end

  def new
    @app = App.new
  end

  def create
    @app = App.new(app_parameters)
    if @app.save
      flash[:notice] = "App #{@app.name} successfully created"
      redirect_to @app
    else
      render :new
    end
  end

  def destroy
    @app = App.find(params[:id])
    if @app.default_app?
      flash[:error] = "Can't delete the default App"
    else
      flash[:notice] = "App #{@app.name} successfully removed"
      @app.destroy
    end
    redirect_to apps_path
  end

  def edit
    @app = App.find(params[:id])
  end

  def update
    @app = App.find(params[:id])
    if @app.update_attributes(app_parameters)
      flash[:notice] = "App #{@app.name} successfully updated"
      redirect_to @app
    else
      render :edit
    end
  end

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
    app = App.find(params[:id])
    @public = app.dkim_public_key
    @private = app.dkim_private_key
  end

  private

  def app_parameters
    params.require(:app).permit(:name, :url, :custom_tracking_domain, :open_tracking_enabled, :click_tracking_enabled)
  end
end
