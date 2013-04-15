class DeliveryController < ApplicationController
  def open_track
    # TODO Record it
    # This sends a 1x1 transparent gif
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
  end
end