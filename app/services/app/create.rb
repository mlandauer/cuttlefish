class App::Create < ApplicationService
  def initialize(current_admin:, name:,
    open_tracking_enabled:, click_tracking_enabled:, custom_tracking_domain:,
    from_domain:
  )
    @current_admin = current_admin
    @name = name
    @open_tracking_enabled = open_tracking_enabled
    @click_tracking_enabled = click_tracking_enabled
    @custom_tracking_domain = custom_tracking_domain
    @from_domain = from_domain
  end

  def call
    app = App.new(
      team: current_admin.team,
      name: name,
      open_tracking_enabled: open_tracking_enabled,
      click_tracking_enabled: click_tracking_enabled,
      custom_tracking_domain: custom_tracking_domain,
      from_domain: from_domain
    )
    unless AppPolicy.new(current_admin, app).create?
      @error_type = :permission
      fail! OpenStruct.new(
        type: :permission,
        message: "You don't have permissions to do this"
      )
      return
    end
    if app.save
      success!
    else
      fail! OpenStruct.new(
        type: :save,
        message: "Save failed"
      )
    end
    app
  end

  private

  attr_reader :current_admin, :name,
    :open_tracking_enabled, :click_tracking_enabled, :custom_tracking_domain,
    :from_domain
end
