class Api::V1::UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
    
  def create
    user = User.new(user_params)

    if user.save
      member_role = Role.find_by(name: "Member")
      user.roles << member_role if member_role

      token = JsonWebToken.encode(user_id: user.id)

      render json: {
        token: token,
        user: {
          id: user.id,
          email: user.email,
          name: user.full_name,
          roles: user.roles.pluck(:name)
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :last_name, :birth_date, :password, :password_confirmation)
  end
end
