FactoryBot.define do
  factory :roles_permission do
    association :role
    association :permission
  end
end
