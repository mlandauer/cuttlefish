class LinksController < ApplicationController
  def index
    @links = Link.joins(:click_events).group(:link_id).select('links.*, count(link_id) as link_count').order("link_count desc").page(params[:page])
  end
end
