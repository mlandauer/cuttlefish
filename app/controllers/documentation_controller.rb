class DocumentationController < ApplicationController
  def index
    @active_app = App.first
  end
end
