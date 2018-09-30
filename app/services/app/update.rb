class App::Update < ApplicationService
  def initialize(
    current_admin:,
    id:,
    attributes:
  )
    @current_admin = current_admin
    @id = id
    # Really crude way to enforce only allow certain attributes
    @attributes = {
      name: attributes[:name],
      open_tracking_enabled: attributes[:open_tracking_enabled],
      click_tracking_enabled: attributes[:click_tracking_enabled],
      custom_tracking_domain: attributes[:custom_tracking_domain],
      from_domain: attributes[:from_domain]
    }
  end

  def call
    app = App.find_by(id: id)
    if app.nil? || !AppPolicy.new(current_admin, app).update?
      fail! OpenStruct.new(
        type: :permission,
        message: "You don't have permissions to do this"
      )
      return
    end
    if app.update_attributes(attributes)
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

  attr_reader :current_admin, :id, :attributes
end
