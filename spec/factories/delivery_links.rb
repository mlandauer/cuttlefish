# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :delivery_link do
    delivery
    link
    click_events []
  end
end
