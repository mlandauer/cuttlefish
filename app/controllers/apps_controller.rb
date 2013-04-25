class AppsController < ApplicationController
  def index
    @apps = App.all
  end

  def show
    @app = App.find(params[:id])
  end

  def new
    # TODO Extract this
    @default_open_tracking_domain = Rails.configuration.action_mailer.default_url_options[:host]
    @app = App.new
  end

  def create
    # TODO Extract this
    @default_open_tracking_domain = Rails.configuration.action_mailer.default_url_options[:host]
    @app = App.new(app_parameters)
    if @app.save
      flash[:notice] = "App #{@app.name} successfully created"
      # TODO: Redirect to the app page to show instructions on how to send mail for this app
      redirect_to apps_path
    else
      render :new
    end
  end

  def destroy
    @app = App.find(params[:id])
    @app.destroy
    redirect_to apps_path
  end

  private

  def app_parameters
    params.require(:app).permit(:name, :description, :url, :open_tracking_domain)
  end
end