
require 'faker'
puts "Seeding database..."
if Rails.env.development?
  [ Borrowing, Copy, Book, Borrowable, UserRole, RolePermission, User, Role, Permission, ItemType ].each(&:delete_all)
end


book_type = ItemType.find_or_create_by(name: "Book") do |item|
  item.loan_duration_days = 14
  item.max_renewals = 2
end


resources = %w[borrowable copy user borrowing role permission item_type]
actions = %w[create read update delete manage]

resources.each do |resource|
  actions.each do |action|
    Permission.find_or_create_by(
      resource: resource,
      action: action
    ) do |permission|
      permission.name = "#{action.titleize} #{resource.titleize}"
      permission.description = "Permission to #{action} #{resource} records"
    end
  end
end

puts "Created #{Permission.count} permissions."

librarian_role = Role.find_or_create_by(name: "Librarian") do |role|
  role.description = "Manage borrowings, items and basic user operations"
end


member_role = Role.find_or_create_by(name: "Member") do |role|
  role.description = "Basic member access - can view and borrow items"
end


librarian_permissions = Permission.where(
  resource: %w[borrowable copy borrowing user item_type],
  action: %w[create read update delete]
)

librarian_role.permissions = librarian_permissions
member_permissions = Permission.where(
  resource: %w[borrowable],
  action: %w[read]
)

member_role.permissions = member_permissions

librarian_user = User.find_or_create_by(email: "librarian@library.com") do |user|
  user.name = "María"
  user.last_name = "González"
  user.birth_date = Date.new(1985, 5, 15)
  user.password = "password123"
end

librarian_user.roles << librarian_role unless librarian_user.roles.include?(librarian_role)

puts "creating users..."
50.times do
  user = User.create!(
    name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    birth_date: Faker::Date.birthday(min_age: 16, max_age: 80),
    password: "password123"
  )

  user.roles << member_role
end


book_genres = [
  "Fiction", "Mystery", "Romance", "Science Fiction", "Fantasy",
  "Biography", "History", "Self-Help", "Business", "Health",
  "Travel", "Cooking", "Art", "Religion", "Philosophy"
]

puts "creating books..."
150.times do
  Book.create!(
    title: Faker::Book.title,
    item_type: book_type,
    author: Faker::Book.author,
    genre: book_genres.sample,
    isbn: Faker::Code.isbn
  )
end

copy_conditions = [ "Excellent", "Good", "Fair", "Poor" ]

puts "creating copies..."
Borrowable.find_each do |borrowable|
  copies_count = rand(1..5)

  copies_count.times do |i|
    Copy.create!(
      borrowable: borrowable,
      condition: copy_conditions.sample,
      status: i == 0 ? :available : [ :available, :available, :borrowed, :maintenance ].sample
    )
  end

  borrowable.update!(copies_count: borrowable.copies.count)
end

regular_users = User.joins(:roles).where(roles: { name: [ "Member", "Student" ] })
available_copies = Copy.where(status: :available).limit(100)

50.times do
  user = regular_users.sample
  copy = available_copies.sample
  next if copy.nil?

  borrowed_at = Faker::Date.between(from: 30.days.ago, to: Date.current)
  loan_duration = copy.borrowable.item_type.loan_duration_days
  due_at = borrowed_at + loan_duration.days

  borrowing = Borrowing.create!(
    user: user,
    copy: copy,
    borrowed_at: borrowed_at,
    due_at: due_at,
    renewal_count: [ 0, 0, 0, 1, 2 ].sample
  )
  copy.update!(status: :borrowed)
  available_copies.delete(copy)
end

80.times do
  user = regular_users.sample
  copy = Copy.available.sample
  next if copy.nil?

  borrowed_at = Faker::Date.between(from: 6.months.ago, to: 2.months.ago)
  loan_duration = copy.borrowable.item_type.loan_duration_days
  due_at = borrowed_at + loan_duration.days
  returned_at = Faker::Date.between(from: borrowed_at, to: due_at + rand(0..7).days)

  Borrowing.create!(
    user: user,
    copy: copy,
    borrowed_at: borrowed_at,
    due_at: due_at,
    returned_at: returned_at,
    renewal_count: [ 0, 0, 1, 1, 2 ].sample
  )
end

10.times do
  user = regular_users.sample
  copy = Copy.available.sample
  next if copy.nil?

  borrowed_at = Faker::Date.between(from: 45.days.ago, to: 30.days.ago)
  loan_duration = copy.borrowable.item_type.loan_duration_days
  due_at = borrowed_at + loan_duration.days

  borrowing = Borrowing.create!(
    user: user,
    copy: copy,
    borrowed_at: borrowed_at,
    due_at: due_at,
    renewal_count: rand(0..2)
  )

  copy.update!(status: :borrowed)
end

puts "BD has been seeded"
