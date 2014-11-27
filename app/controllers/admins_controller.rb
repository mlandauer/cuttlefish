class AdminsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @admin = Admin.new
    @admins = policy_scope(Admin)
  end
end
