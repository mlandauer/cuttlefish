class TrackingController < ApplicationController
  # We need this controller to be accessible by anyone without authentication
  skip_filter :authenticate_admin!
  # SSL redirection is also disabled for this controller. See ApplicationController force_ssl.

  def open
    delivery = Delivery.find(params[:delivery_id])
    if delivery.open_tracked_hash == params[:hash]
      delivery.add_open_event(request)
      # TODO Check that we are asking for a gif and only accept those for the time being
      # This sends a 1x1 transparent gif
      send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  # Just do the redirect for the time being
  # TODO: record the click
  def link
    delivery_link = DeliveryLink.find(params[:delivery_link_id])
    if delivery_link.hash == params[:hash]
      # TODO: Record the click here
      redirect_to delivery_link.url
    else
      raise ActiveRecord::RecordNotFound
    end      
  end
end