# frozen_string_literal: true

FactoryBot.define do
  factory :email do
    # The from_address is populated automatically on save from the "data" field
    # Setting it here to just make things a little easier in some testing
    from_address factory: :address
    app
    ignore_deny_list { false }
    disable_css_inlining { false }
  end
end
