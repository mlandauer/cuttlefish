# frozen_string_literal: true

FactoryBot.define do
  factory :app do
    team
    name { "My App" }
  end
end
