class BlackListsController < ApplicationController
  def index
    @black_lists = BlackList.all.order(created_at: :desc).page(params[:page])
  end
end
