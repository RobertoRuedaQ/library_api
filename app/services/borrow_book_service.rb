class BorrowBookService
  attr_reader :user, :copy_id, :borrowing, :error

  def initialize(user:, copy_id:)
    @user = user
    @copy_id = copy_id
    @borrowing = nil
    @error = nil
  end

  def call
    copy = Copy.available.find_by(id: copy_id)
    return failure("Copy not available") unless copy

    @borrowing = user.borrowings.build(
      copy: copy,
      borrowed_at: Time.zone.now,
      due_at: copy.due_date
    )

    ActiveRecord::Base.transaction do
      if @borrowing.save
        copy.update!(status: :borrowed)
        success(@borrowing)
      else
        failure(@borrowing.errors.full_messages.join(", "))
      end
    end
  rescue => e
    failure(e.message)
  end

  private

  def success(borrowing)
    @borrowing = borrowing
    @error = nil
    true
  end

  def failure(message)
    @borrowing = nil
    @error = message
    false
  end
end
