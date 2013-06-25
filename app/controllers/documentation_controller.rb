class DocumentationController < ApplicationController
  def index
    @active_app = App.where(default_app: false).first
  end
end
