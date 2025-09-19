class Api::V1::DashboardController < ApplicationController
  def show
    return render json: { error: "Unauthorized" }, status: :unauthorized unless current_user

    serializer = librarian? ? LibrarianDashboardSerializer : MemberDashboardSerializer

    render json: current_user, serializer: serializer, status: :ok
  end
end
