class Api::V1::BooksController < ApplicationController
  skip_before_action :authorize_request, only: [ :index, :show ]
  before_action :set_book, only: [ :show, :update, :destroy ]
  before_action :authorize_librarian!, only: [ :create, :update, :destroy ]

  def index
    filters = params.slice(:title, :author, :genre)
    books = Book.filter_by(filters)
      .paginate(page: params[:page], per_page: 10)
    
    render json: {
      books: books,
      meta: {
        current_page: books.current_page,
        total_pages: books.total_pages,
        total_entries: books.total_entries
      }
    }, status: :ok
  end

  def show
    render json: @book, serializer: BookSerializer, status: :ok
  end

  def create
    book = Book.new(book_params)
    if book.save
      render json: book, serializer: BookSerializer, status: :ok
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    head :no_content
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :item_type_id)
  end
end
