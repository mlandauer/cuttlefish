# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :app_deny_list do
    app
    address
    caused_by_delivery factory: :delivery
  end
end
