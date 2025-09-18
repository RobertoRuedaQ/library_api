FactoryBot.define do
  factory :copy do
    borrowable { nil }
    condition { "MyString" }
    status { 1 }
  end
end
