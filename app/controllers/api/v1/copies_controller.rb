class Api::V1::CopiesController < ApplicationController
  before_action :authorize_librarian!
  before_action :set_copy, only: [ :show, :update, :destroy ]

  def index
    copies = if params[:book_id]
           Copy.where(borrowable_id: params[:book_id]).paginate(page: params[:page], per_page: params[:per_page] || 10)
    else
           Copy.paginate(page: params[:page], per_page: params[:per_page] || 10)
    end


    render json: {
      copies: copies.as_json(include: :borrowable),
      meta: {
        current_page: copies.current_page,
        total_pages: copies.total_pages,
        total_count: copies.total_entries
      }
    }, status: :ok
  end

  def show
    render json: @copy, status: :ok
  end

  def create
    copy = Copy.new(copy_params)
    copy.borrowable_id ||= params[:book_id]

    if copy.save
      render json: copy, status: :created
    else
      render json: { error: copy.errors.full_messages.join(", ") }, status: :unprocessable_content
    end
  end

  def update
    if @copy.update(copy_params)
      render json: @copy, status: :ok
    else
      render json: { error: @copy.errors.full_messages.join(", ") }, status: :unprocessable_content
    end
  end

  def destroy
    @copy.destroy
    head :no_content
  end

  private

  def set_copy
    @copy = Copy.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Copy not found" }, status: :not_found
  end

  def copy_params
    params.require(:copy).permit(:borrowable_id, :condition, :status)
  end
end
