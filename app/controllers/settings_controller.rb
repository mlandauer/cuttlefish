class SettingsController < ApplicationController
  def edit
    @smtp_all_authenticated = Settings.smtp_all_authenticated
  end

  def update
    Settings.smtp_all_authenticated = !!params[:smtp_all_authenticated]
    flash[:notice] = "Global settings updated"
    redirect_to edit_settings_url
  end
end
