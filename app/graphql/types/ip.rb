# frozen_string_literal: true

module Types
  class IP < GraphQL::Schema::Object
    field :address, String, null: false
    field :country, String, null: true

    # Should return nil if we can't access the ip service
    def country
      r = query(object[:address])
      r["country"] if r
    end

    private

    # TODO: Should return nil if there was a problem
    def query(address)
      BatchLoader.for(address).batch do |addresses, loader|
        addresses.uniq.each do |a|
          # Run a query at ip-api.com to get more information about this
          # ip address
          r = RestClient.get("http://ip-api.com/json/#{a}")
          result = JSON.parse(r.body)
          result = nil if result["status"] != "success"
          loader.call(a, result)
        end
      end
    end
  end
end
