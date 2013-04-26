class TrackingController < ApplicationController
  # We need this controller to be accessible by anyone without authentication
  skip_filter :authenticate_admin!
  # SSL redirection is also disabled for this controller. See ApplicationController force_ssl.

  def open
    Delivery.find_by!(open_tracked_hash: params[:hash]).open_events.create!(
      user_agent: request.env['HTTP_USER_AGENT'],
      referer: request.referer,
      ip: request.remote_ip
    )
    # TODO Check that we are asking for a gif and only accept those for the time being
    # This sends a 1x1 transparent gif
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
  end
end