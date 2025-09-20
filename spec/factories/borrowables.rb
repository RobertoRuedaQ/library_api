FactoryBot.define do
  factory :borrowable do
    title { "MyString" }
    item_type { nil }
    copies_count { 1 }
    type { "" }
  end
end
