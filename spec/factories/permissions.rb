FactoryBot.define do
  factory :permission do
    name { "MyString" }
    resource { "MyString" }
    action { 1 }
    description { "MyText" }
  end
end
