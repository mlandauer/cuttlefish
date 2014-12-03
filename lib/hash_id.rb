module HashId
  def self.hash(id)
    Digest::SHA1.hexdigest(ENV["CUTTLEFISH_HASH_SALT"] + id.to_s)
  end

  def self.valid?(id, h)
    hash(id) == h
  end
end
