require 'rails_helper'

RSpec.describe "Api::V1::Borrowings", type: :request do
  let(:librarian_role) { create(:role, name: "Librarian") }
  let(:member_role) { create(:role, name: "Member") }

  let(:librarian) { create(:user, roles: [ librarian_role ]) }
  let(:member) { create(:user, roles: [ member_role ]) }

  let(:item_type) { create(:book_item_type) }
  let(:borrowable) { create(:book, item_type: item_type) }
  let!(:copy) { create(:copy, borrowable: borrowable, status: :available) }

  let(:headers_member) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: member.id)}" } }
  let(:headers_librarian) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: librarian.id)}" } }

  describe "GET /borrowings" do
    let!(:borrowing) { create(:borrowing, user: member, copy: copy, borrowed_at: Time.current, due_at: 14.days.from_now) }

    it "returns current user's borrowings" do
      get "/api/v1/borrowings", headers: headers_member
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(borrowing.id)
      expect(json.first["copy"]["id"]).to eq(copy.id)
    end
  end

  describe "POST /borrowings" do
    it "allows member to borrow an available copy" do
      post "/api/v1/borrowings", params: { copy_id: copy.id }, headers: headers_member
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["copy"]["id"]).to eq(copy.id)
      expect(copy.reload.status).to eq("borrowed")
    end

    it "returns error if copy is not available" do
      copy.update!(status: :borrowed)
      post "/api/v1/borrowings", params: { copy_id: copy.id }, headers: headers_member
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("Copy not available")
    end
  end

  describe "PATCH /borrowings/:id/return" do
    let!(:borrowing) { create(:borrowing, user: member, copy: copy, borrowed_at: Time.current, due_at: copy.due_date) }

    it "allows librarian to mark borrowing as returned" do
      patch "/api/v1/borrowings/#{borrowing.id}/return", headers: headers_librarian
      expect(response).to have_http_status(:ok)
      expect(borrowing.reload.returned_at).not_to be_nil
      expect(copy.reload.status).to eq("available")
    end

    it "prevents member from returning" do
      patch "/api/v1/borrowings/#{borrowing.id}/return", headers: headers_member
      expect(response).to have_http_status(:forbidden)
    end

    it "returns error if already returned" do
      borrowing.return_item!
      patch "/api/v1/borrowings/#{borrowing.id}/return", headers: headers_librarian
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("Already returned")
    end
  end

  describe "PATCH /borrowings/:id/renew" do
    let!(:borrowing) { create(:borrowing, user: member, copy: copy, borrowed_at: Time.current, due_at: 14.days.from_now, renewal_count: 0) }

    it "allows member to renew if allowed" do
      patch "/api/v1/borrowings/#{borrowing.id}/renew", headers: headers_member
      expect(response).to have_http_status(:ok)
      expect(borrowing.reload.renewal_count).to eq(1)
    end

    it "prevents renewal if max_renewals reached" do
      borrowing.update!(renewal_count: 2) # max_renewals from item_type
      patch "/api/v1/borrowings/#{borrowing.id}/renew", headers: headers_member
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("Cannot renew borrowing")
    end
  end
end
