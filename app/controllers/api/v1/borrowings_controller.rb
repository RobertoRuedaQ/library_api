class Api::V1::BorrowingsController < ApplicationController
  before_action :authorize_request
  before_action :authorize_librarian!, only: [ :return ]

  def index
    if librarian?
      borrowings = Borrowing.includes(copy: :borrowable, user: {})
    else
      borrowings = current_user.borrowings.includes(copy: :borrowable)
    end

    case params[:scope]
    when "active"
      borrowings = borrowings.active
    when "overdue"
      borrowings = borrowings.overdue
    when "returned"
      borrowings = borrowings.where.not(returned_at: nil)
    end

    borrowings = borrowings.order(due_at: :asc)

    render json: borrowings, each_serializer: BorrowingSerializer, status: :ok
  end

  def create
    service = BorrowBookService.new(user: current_user, copy_id: params[:copy_id])

    if service.call
      render json: service.borrowing, serializer: BorrowingSerializer, status: :created
    else
      render json: { error: service.error || "Copy not available" }, status: :unprocessable_entity
    end
  end

  def return
    borrowing = Borrowing.find(params[:id])

    if borrowing.returned_at.present?
      return render json: { error: "Already returned" }, status: :unprocessable_entity
    end

    if borrowing.return_item!
      render json: { message: "Book returned successfully" }, status: :ok
    else
      render json: { error: "Failed to return book" }, status: :unprocessable_entity
    end
  end

  def renew
    borrowing = current_user.borrowings.find(params[:id])

    if borrowing.renew!
      render json: borrowing, serializer: BorrowingSerializer, status: :ok
    else
      render json: { error: "Cannot renew borrowing" }, status: :unprocessable_entity
    end
  end
end
