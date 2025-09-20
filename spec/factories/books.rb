FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "#{Faker::Book.title} #{n}" }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    isbn { Faker::Code.isbn }
    association :item_type, factory: :book_item_type
  end
end
