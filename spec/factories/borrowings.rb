FactoryBot.define do
  factory :borrowing do
    user { nil }
    copy { nil }
    borrowed_at { nil }
    due_at { nil }
    returned_at { nil }
    renewal_count { 1 }
  end
end
