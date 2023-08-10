# frozen_string_literal: true

module Types
  class IPInfo < GraphQL::Schema::Object
    field :city, String, null: false
    field :country, String, null: false
    field :country_code, String, null: false
    field :isp, String, null: false
    field :lat, Float, null: false
    field :lng, Float, null: false
    field :org, String, null: false
    field :region, String, null: false
    field :region_name, String, null: false
    field :timezone, String, null: false
  end
end
