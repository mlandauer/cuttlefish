class DeliveryLink < ActiveRecord::Base
  belongs_to :link
  has_many :link_events

  def hash
    # TODO: Move the salt to configuration
    salt = "my salt"
    Digest::SHA1.hexdigest(salt + id.to_s)    
  end

  def valid_hash?(h)
    hash == h
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
