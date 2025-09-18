FactoryBot.define do
  factory :item_type do
    name { "MyString" }
    loan_duration_days { 1 }
    max_renewals { 1 }
  end
end
