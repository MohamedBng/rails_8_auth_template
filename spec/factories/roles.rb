FactoryBot.define do
  factory :role do
    name { Faker::Lorem.unique.word }

    trait :admin do
      name { 'admin' }

      trait :with_permissions do
        after(:create) do |role|
          create_list(:permission, 3, roles: [ role ])
        end
      end
    end

    trait :user do
      name { 'user' }
    end
  end
end
