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
    # TODO: Handle id not found
    app = App.find(id)
    if !AppPolicy.new(current_admin, app).update?
      fail! OpenStruct.new(
        type: :permission,
        message: "You don't have permissions to do this"
      )
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
      fail! OpenStruct.new(
        type: :save,
        message: "Save failed"
      )
    end
    app
  end

  private

  attr_reader :current_admin, :id, :name, :open_tracking_enabled,
    :click_tracking_enabled, :custom_tracking_domain, :from_domain
end
