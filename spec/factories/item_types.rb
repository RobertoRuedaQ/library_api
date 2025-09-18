FactoryBot.define do
  factory :book_item_type, class: ItemType do
    initialize_with { ItemType.find_or_create_by(name: "Book") }
    name { "Book" }
    loan_duration_days { 7 }
    max_renewals { 0 }
  end
end
