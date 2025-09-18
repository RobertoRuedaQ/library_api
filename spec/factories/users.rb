FactoryBot.define do
  factory :user do
    email { "MyString" }
    name { "MyString" }
    last_name { "MyString" }
    birth_date { "2025-09-18" }
    password_digest { "MyString" }
  end
end
