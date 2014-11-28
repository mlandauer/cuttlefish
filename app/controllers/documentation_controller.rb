class DocumentationController < ApplicationController
  def index
    @apps = policy_scope(App)
    @active_app = @apps.first
  end
end
