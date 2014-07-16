class BlackListsController < ApplicationController
  def index
    @black_lists = BlackList.all.page(params[:page])
  end
end
