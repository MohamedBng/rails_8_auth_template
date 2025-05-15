FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    phone { Faker::PhoneNumber.phone_number }
    description { Faker::Lorem.paragraph }

    transient do
      permissions_list { [] }
    end

    after(:create) do |user, evaluator|
      user.roles << Role.find_or_create_by!(name: "user") if user.roles.empty?

      evaluator.permissions_list.each do |permission_name|
        permission = Permission.find_or_create_by(name: permission_name)
        user.roles.first.permissions << permission unless user.roles.first.permissions.include?(permission)
      end
    end
  end
end
