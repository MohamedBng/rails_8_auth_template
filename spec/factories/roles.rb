FactoryBot.define do
  factory :role do
    name { Faker::Lorem.unique.word }

    trait :admin do
      name { 'admin' }
    end

    trait :user do
      name { 'user' }
    end
  end
end
