class BorrowingSerializer < ActiveModel::Serializer
  attributes :id, :user, :copy, :borrowed_at, :due_date, :returned_at

  def user
    borrowing.user.full_name
  end

  def copy
    borrowing.copy
  end

  def borrowed_at
    borrowing.borrowed_at.strftime("%Y %m %d")
  end

  def due_date
    borrowing.due_at.strftime("%Y %m %d")
  end

  def returned_at
    borrowing.returned_at&.strftime("%Y %m %d")
  end

  private

  def borrowing
    object
  end
end
