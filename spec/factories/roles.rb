FactoryBot.define do
  factory :role do
    name { "Member" }

    trait :librarian do
      name { "Librarian" }
    end
  end
end
