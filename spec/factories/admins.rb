FactoryBot.define do
  factory :admin do
    sequence :email do |n|
      "person#{n}@foo.com"
    end
    password "password"
    team
  end
end
