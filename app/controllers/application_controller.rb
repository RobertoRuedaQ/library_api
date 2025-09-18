class ApplicationController < ActionController::API
  before_action :authorize_request

  protected

  def authorize_librarian!
    unless current_user&.roles&.exists?(name: "Librarian")
      render json: { error: "Forbidden: Librarian role required" }, status: :forbidden
    end
  end



  private

  def authorize_request
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def current_user
    return @current_user if defined?(@current_user)

    header = request.headers["Authorization"]
    token  = header.split(" ").last if header.present?

    if token
      decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
    else
      @current_user = nil
    end
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    @current_user = nil
  end

  def authorize!(resource, action)
    unless current_user&.has_permission?(resource, action)
      render json: { error: "Forbidden: You don’t have permission for this action" }, status: :forbidden
    end
  end
end
