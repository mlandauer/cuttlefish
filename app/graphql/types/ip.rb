# frozen_string_literal: true

module Types
  class IP < GraphQL::Schema::Object
    field :address, String, null: false
    field :info, Types::IPInfo, null: true

    def info
      r = query(object[:address])
      return if r.nil?

      # We're writing this out explicitly so we're not binding
      # our parameter names directly to those returned by the
      # service
      {
        country: r["country"],
        country_code: r["countryCode"],
        region: r["region"],
        region_name: r["regionName"],
        city: r["city"],
        lat: r["lat"],
        lng: r["lng"],
        timezone: r["timezone"],
        isp: r["isp"],
        org: r["org"]
      }
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
