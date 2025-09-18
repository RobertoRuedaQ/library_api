require 'rails_helper'

require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    let!(:member_role) { Role.create!(name: "Member", description: "Default member role") }

    let(:valid_params) do
      {
        user: {
          email: "test@example.com",
          name: "Test",
          last_name: "User",
          birth_date: "2000-01-01",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          email: "invalid-email",
          name: "",
          last_name: "",
          birth_date: "",
          password: "123",
          password_confirmation: "321"
        }
      }
    end

    context "with valid params" do
      it "creates a new user and returns a JWT token" do
        post "/api/v1/users", params: valid_params

        expect(response).to have_http_status(:created)
        
        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("test@example.com")
        expect(json["user"]["roles"]).to include("Member")
      end
    end

    context "with invalid params" do
      it "does not create a user and returns errors" do
        post "/api/v1/users", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_an(Array)
        expect(json["errors"]).to include("Email is invalid")
      end
    end
  end
end
