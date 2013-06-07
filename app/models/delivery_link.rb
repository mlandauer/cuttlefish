class DeliveryLink < ActiveRecord::Base
  belongs_to :link
  has_many :link_events

  # Don't call a method hash it will stop associations on this model from working
  def link_hash
    HashId.hash(id)
  end

  def valid_hash?(h)
    HashId.valid?(id, h)
  end

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
