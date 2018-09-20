class DocumentationController < ApplicationController
  def index
    result = api_query :documentation
    @apps = result.data.apps
    @active_app = @apps.first
  end
end
