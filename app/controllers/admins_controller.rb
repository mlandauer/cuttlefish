class AdminsController < ApplicationController
  def index
    @admin = Admin.new
    @admins = Admin.all
  end
end
