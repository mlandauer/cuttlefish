class App::Destroy < ApplicationService
  def initialize(current_admin:, id:)
    @current_admin = current_admin
    @id = id
  end

  def call
    app = App.find_by(id: id)
    if app && AppPolicy.new(current_admin, app).destroy?
      success!
      app.destroy
    else
      fail! "Couldn't remove app. You probably don't have the necessary permissions."
    end
  end

  private

  attr_reader :current_admin, :id
end
