class DeliveryController < ApplicationController
  def open_track
    Delivery.find(params[:id]).open_events.create!
    # TODO Check that we are asking for a gif and only accept those for the time being
    # TODO Record it
    # This sends a 1x1 transparent gif
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
  end
end