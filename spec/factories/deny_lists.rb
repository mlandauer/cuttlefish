# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :deny_list do
    app
    address
    caused_by_postfix_log_line factory: :postfix_log_line
  end
end
