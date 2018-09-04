class DenyListsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @deny_lists = policy_scope(DenyList).order(created_at: :desc).page(params[:page])
  end

  def destroy
    deny_list = DenyList.find(params[:id])
    authorize deny_list
    deny_list.destroy
    redirect_to :back
  end
end
