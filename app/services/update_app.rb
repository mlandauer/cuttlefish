class UpdateApp < ApplicationService
  def initialize(
    current_admin:,
    id:,
    name:,
    open_tracking_enabled:,
    click_tracking_enabled:,
    custom_tracking_domain:,
    from_domain:
  )
    @current_admin = current_admin
    @id = id
    @name = name
    @open_tracking_enabled = open_tracking_enabled
    @click_tracking_enabled = click_tracking_enabled
    @custom_tracking_domain = custom_tracking_domain
    @from_domain = from_domain
  end

  def call
    app = App.find(id)
    if !AppPolicy.new(current_admin, app).update?
      # TODO: Make this a symbol
      # TODO: Make this returned as part of a a struct in an error
      @error_type = 'PERMISSION'
      fail! "You don't have permissions to do this"
      return
    end
    if app.update_attributes(
      name: name,
      open_tracking_enabled: open_tracking_enabled,
      click_tracking_enabled: click_tracking_enabled,
      custom_tracking_domain: custom_tracking_domain,
      from_domain: from_domain
    )
      success!
    else
      @error_type = 'SAVE'
      fail! "Save failed"
    end
    app
  end

  attr_reader :error_type

  private

  attr_reader :current_admin, :id, :name, :open_tracking_enabled,
    :click_tracking_enabled, :custom_tracking_domain, :from_domain
end
