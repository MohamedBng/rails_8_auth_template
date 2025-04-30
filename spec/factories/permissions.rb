FactoryBot.define do
  factory :permission do
    name { Faker::Lorem.unique.word }
    description { Faker::Lorem.sentence }
  end
end
