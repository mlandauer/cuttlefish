module HashId
  def self.hash(id)
    # TODO: Move the salt to configuration
    salt = "my salt"
    Digest::SHA1.hexdigest(salt + id.to_s)
  end

  def self.valid?(id, h)
    hash(id) == h
  end
end
