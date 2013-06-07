class DeliveryLink < ActiveRecord::Base
  belongs_to :link
  has_many :link_events

  def url
    link.url
  end

  def add_link_event(request)
    link_events.create!(
      user_agent: request.env['HTTP_USER_AGENT'],
      referer: request.referer,
      ip: request.remote_ip
    )    
  end
end
