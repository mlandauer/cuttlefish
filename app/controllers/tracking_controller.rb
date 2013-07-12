class TrackingController < ApplicationController
  # We need this controller to be accessible by anyone without authentication
  skip_filter :authenticate_admin!
  # SSL redirection is also disabled for this controller. See ApplicationController force_ssl.

  def open
    if HashId.valid?(params[:delivery_id], params[:hash])
      delivery = Delivery.find(params[:delivery_id])
      delivery.add_open_event(request)
      # TODO Check that we are asking for a gif and only accept those for the time being
      # This sends a 1x1 transparent gif
      send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline")
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def link
    if HashId.valid?(params[:delivery_link_id], params[:hash])
      delivery_link = DeliveryLink.find(params[:delivery_link_id])
      delivery_link.add_click_event(request)
      redirect_to delivery_link.url
    else
      raise ActiveRecord::RecordNotFound
    end      
  end
end