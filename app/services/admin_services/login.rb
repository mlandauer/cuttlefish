# frozen_string_literal: true

module AdminServices
  class Login < ApplicationService
    def initialize(email:, password:)
      super()
      @email = email
      @password = password
    end

    def call
      admin = Admin.find_by(email: email)
      # TODO: Also do the hashing (and throw away the result) if admin is nil
      if admin&.valid_password?(password)
        token = JWT.encode(jwt_payload(admin), jwt_secret, "HS512")
        success!
        [admin, token]
      else
        fail!
      end
    end

    # Token has expiry time of 1 hour
    def exp
      Time.now.to_i + 3600
    end

    # Keeping the claims to an absolute minimum for the time being
    def jwt_payload(admin)
      { admin_id: admin.id, exp: exp, site_admin: admin.site_admin }
    end

    def jwt_secret
      ENV.fetch("JWT_SECRET", nil)
    end

    private

    attr_reader :email, :password
  end
end
