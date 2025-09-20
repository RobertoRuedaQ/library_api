require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { User.create!(email: "test@example.com", password: "password123", name: "Test", last_name: "User", birth_date: "1990-01-01") }

  describe "POST /login" do
    context "with valid credentials" do
      it "returns a JWT token" do
        post api_v1_login_path, params: { email: user.email, password: 'password123' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key("token")
      end
    end

    context "with invalid credentials" do
      it "returns an unauthorized status" do
        post api_v1_login_path, params: { email: user.email, password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
