# frozen_string_literal: true

class TrackingController < ApplicationController
  # SSL redirection is also disabled for this controller. See
  # ApplicationController force_ssl.

  def open
    raise ActiveRecord::RecordNotFound unless HashId.valid?(params[:delivery_id], params[:hash])

    delivery = Delivery.find(params[:delivery_id])

    delivery.add_open_event(request) unless Rails.configuration.cuttlefish_read_only_mode
    # TODO: Check that we are asking for a gif and only accept those for
    # the time being
    # This sends a 1x1 transparent gif
    send_data(
      Base64.decode64(
        "R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
      ),
      type: "image/gif",
      disposition: "inline"
    )
  end

  def click
    if HashId.valid?(
      "#{params[:delivery_link_id]}-#{params[:url]}",
      params[:hash]
    )
      delivery_link = DeliveryLink.find_by_id(params[:delivery_link_id])
      # If there is no delivery_link this is probably an old email
      # which has been archived and the delivery_link record doesn't exist
      # anymore.
      delivery_link.add_click_event(request) if delivery_link && !Rails.configuration.cuttlefish_read_only_mode
      redirect_to params[:url]
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
