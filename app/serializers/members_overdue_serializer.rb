class MembersOverdueSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :overdue_books_count

  def name
    "#{object.name} #{object.last_name}"
  end

  def overdue_books_count
    object.borrowings.overdue.count
  end
end
