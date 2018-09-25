class DocumentationController < ApplicationController
  def index
    result = api_query2
    @apps = result.data.apps
    @active_app = @apps.first
  end
end
