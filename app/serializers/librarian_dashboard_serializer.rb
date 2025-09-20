class LibrarianDashboardSerializer < ActiveModel::Serializer
  attributes :total_books, :total_borrowed_books, :books_due_today, :members_with_overdue_books

  def total_books
    Book.count
  end

  def total_borrowed_books
    Borrowing.active.count
  end

  def books_due_today
    Borrowing.due_today.count
  end

  def members_with_overdue_books
    User.with_overdue_books.map do |user|
      {
        id: user.id,
        name: user.full_name,
        email: user.email,
        overdue_books_count: user.borrowings.overdue.count
      }
    end
  end
end
