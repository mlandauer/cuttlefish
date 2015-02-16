# This implementation of a MAC (message authentication code) has some problems
# So, deprecating its use for a standard implementation of HMAC
module HashId
  def self.hash(id)
    Digest::SHA1.hexdigest(Rails.configuration.cuttlefish_hash_salt + id.to_s)
  end

  def self.valid?(id, h)
    hash(id) == h
  end
end
