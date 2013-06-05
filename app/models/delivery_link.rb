class DeliveryLink < ActiveRecord::Base
  belongs_to :link

  def hash
    # TODO: Move the salt to configuration
    salt = "my salt"
    Digest::SHA1.hexdigest(salt + id.to_s)    
  end

  def url
    link.url
  end
end
