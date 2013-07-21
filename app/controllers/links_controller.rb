class LinksController < ApplicationController
  def index
    @links = Link.joins(:click_events).group(:link_id).select('links.*, count(link_id) as link_count').order("link_count desc").page(params[:page])
  end

  def show
    @link = Link.find(params[:id])
    @delivery_links = @link.delivery_links.joins("LEFT OUTER JOIN click_events ON delivery_links.id = click_events.delivery_link_id").group("delivery_links.id").select("delivery_links.*, count(delivery_link_id) as click_count").order("click_count DESC").page(params[:page])
  end
end
