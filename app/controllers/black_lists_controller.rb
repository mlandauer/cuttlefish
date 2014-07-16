class BlackListsController < ApplicationController
  def index
    @black_lists = BlackList.all.order(created_at: :desc).page(params[:page])
  end

  def destroy
    black_list = BlackList.find(params[:id])
    black_list.destroy
    redirect_to black_lists_path
  end
end
