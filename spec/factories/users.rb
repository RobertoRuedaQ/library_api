FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
    password { "password" }

    trait :librarian do
      after(:create) do |user|
        librarian_role = create(:role, :librarian)
        user.roles << librarian_role
      end
    end

    trait :member do
      after(:create) do |user|
        member_role = create(:role)
        user.roles << member_role
      end
    end
  end
end
