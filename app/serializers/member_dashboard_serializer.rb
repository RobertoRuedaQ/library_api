class MemberDashboardSerializer < ActiveModel::Serializer
  attributes :borrowed_books, :total_overdue

  def borrowed_books
    object.borrowings.includes(copy: :borrowable).map do |b|
      book = b.copy.borrowable
      {
        borrowing_id: b.id,
        book_id: book.id,
        title: book.title,
        borrowed_at: b.borrowed_at.strftime("%Y-%m-%d"),
        due_date: b.due_at.strftime("%Y-%m-%d"),
        returned: b.returned_at.present?,
        overdue: b.overdue?
      }
    end
  end

  def total_overdue
    object.borrowings.overdue.count
  end
end
