FactoryBot.define do
  factory :borrowing do
    user { nil }
    copy { nil }
    borrowed_at { "2025-09-18 13:39:33" }
    due_at { "2025-09-18 13:39:33" }
    returned_at { "2025-09-18 13:39:33" }
    renewal_count { 1 }
  end
end
