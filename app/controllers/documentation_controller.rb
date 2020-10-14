# frozen_string_literal: true

class DocumentationController < ApplicationController
  def index
    result = api_query
    @data = result.data
    @apps = @data.apps
    @active_app = @apps.first
  end
end
