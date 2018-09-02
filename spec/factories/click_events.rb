# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :click_event do
    delivery_link_id 1
    user_agent "MyText"
    referer "MyText"
    ip "MyString"
  end
end
