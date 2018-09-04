class DenyListsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @deny_lists = policy_scope(BlackList).order(created_at: :desc).page(params[:page])
  end

  def destroy
    black_list = BlackList.find(params[:id])
    authorize black_list
    black_list.destroy
    redirect_to :back
  end
end
