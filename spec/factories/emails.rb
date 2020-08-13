# frozen_string_literal: true

FactoryBot.define do
  factory :email do
    app
    ignore_deny_list { false }
  end
end
