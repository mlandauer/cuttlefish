# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :deny_list do
    team
    address_id 1
    caused_by_delivery_id 1
  end
end
