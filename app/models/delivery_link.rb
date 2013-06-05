class DeliveryLink < ActiveRecord::Base
  def hash
    # TODO: Move the salt to configuration
    salt = "my salt"
    Digest::SHA1.hexdigest(salt + id.to_s)    
  end
end
