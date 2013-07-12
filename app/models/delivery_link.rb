class DeliveryLink < ActiveRecord::Base
  belongs_to :link
  has_many :click_events, dependent: :destroy

  def url
    link.url
  end

  def add_click_event(request)
    click_events.create!(
      user_agent: request.env['HTTP_USER_AGENT'],
      referer: request.referer,
      ip: request.remote_ip
    )    
  end
end
