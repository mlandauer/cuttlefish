# frozen_string_literal: true

FactoryBot.define do
  factory :delivery do
    app
    email
    address
  end
end
