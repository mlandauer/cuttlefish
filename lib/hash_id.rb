# frozen_string_literal: true

module HashId
  def self.hash(message)
    # TODO: Rename configuration - it's not a salt, it's a key
    OpenSSL::HMAC.hexdigest(
      "sha1",
      Rails.configuration.cuttlefish_hash_salt,
      message
    )
  end

  def self.valid?(message, given_hash)
    hash(message) == given_hash
  end
end
