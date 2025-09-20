require 'rails_helper'

RSpec.describe "Api::V1::Copies", type: :request do
  let(:librarian_role) { create(:role, name: "Librarian") }
  let(:member_role) { create(:role, name: "Member") }

  let(:librarian) { create(:user, roles: [ librarian_role ]) }
  let(:member) { create(:user, roles: [ member_role ]) }

  let(:headers_librarian) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: librarian.id)}" } }
  let(:headers_member) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: member.id)}" } }

  let(:book) { create(:book) }

  describe "GET /books/:book_id/copies" do
    before do
      create_list(:copy, 15, borrowable: book)
    end

    it "returns paginated copies" do
      get "/api/v1/books/#{book.id}/copies", params: { page: 2, per_page: 10 }, headers: headers_librarian

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["copies"].size).to eq(5)
      expect(json["meta"]["current_page"]).to eq(2)
      expect(json["meta"]["total_pages"]).to eq(2)
      expect(json["meta"]["total_count"]).to eq(15)
    end
  end

  describe "POST /books/:book_id/copies" do
    let(:copy_params) { { condition: "New", status: "available" } }

    it "allows librarian to create a copy" do
      expect {
        post "/api/v1/books/#{book.id}/copies", params: { copy: copy_params }, headers: headers_librarian
      }.to change(Copy, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["condition"]).to eq("New")
      expect(json["status"]).to eq("available")
      expect(json["borrowable_id"]).to eq(book.id)
    end

    it "prevents member from creating a copy" do
      post "/api/v1/books/#{book.id}/copies", params: { copy: copy_params }, headers: headers_member
      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Forbidden: Librarian role required")
    end
  end

  describe "PATCH /copies/:id" do
    let!(:copy) { create(:copy, borrowable: book, condition: "Good", status: "available") }

    it "allows librarian to update a copy" do
      patch "/api/v1/copies/#{copy.id}", params: { copy: { condition: "Used" } }, headers: headers_librarian

      expect(response).to have_http_status(:ok)
      expect(copy.reload.condition).to eq("Used")
    end

    it "prevents member from updating a copy" do
      patch "/api/v1/copies/#{copy.id}", params: { copy: { condition: "Used" } }, headers: headers_member

      expect(response).to have_http_status(:forbidden)
      expect(copy.reload.condition).to eq("Good")
    end
  end

  describe "DELETE /copies/:id" do
    let!(:copy) { create(:copy, borrowable: book) }

    it "allows librarian to delete a copy" do
      expect {
        delete "/api/v1/copies/#{copy.id}", headers: headers_librarian
      }.to change(Copy, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "prevents member from deleting a copy" do
      delete "/api/v1/copies/#{copy.id}", headers: headers_member
      expect(response).to have_http_status(:forbidden)
      expect(Copy.exists?(copy.id)).to be(true)
    end
  end
end
