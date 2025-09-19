require 'rails_helper'

RSpec.describe "Api::V1::Dashboard", type: :request do
  let(:librarian_role) { create(:role, name: "Librarian") }
  let(:member_role) { create(:role, name: "Member") }

  let(:librarian) { create(:user, roles: [ librarian_role ]) }
  let(:member) { create(:user, roles: [ member_role ]) }

  let(:headers_librarian) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: librarian.id)}" } }
  let(:headers_member) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: member.id)}" } }

  let(:book_item_type) { create(:book_item_type, max_renewals: 2, loan_duration_days: 14) }
  let(:book) { create(:book, item_type: book_item_type) }
  let!(:copy) { create(:copy, borrowable: book, status: :available) }

  describe "GET /api/v1/dashboard" do
    context "as a librarian" do
      let!(:borrowing) { create(:borrowing, user: member, copy: copy, borrowed_at: 3.days.ago, due_at: 1.day.ago) }

      it "returns librarian dashboard data" do
        get "/api/v1/dashboard", headers: headers_librarian

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["total_books"]).to eq(Book.count)
        expect(json["total_borrowed_books"]).to eq(Borrowing.active.count)
        expect(json["books_due_today"]).to eq(Borrowing.due_today.count)
        expect(json["members_with_overdue_books"].first["id"]).to eq(member.id)
        expect(json["members_with_overdue_books"].first["overdue_books_count"]).to eq(member.borrowings.overdue.count)
      end
    end

    context "as a member" do
      let!(:borrowing) { create(:borrowing, user: member, copy: copy, borrowed_at: 1.day.ago, due_at: 2.days.from_now) }

      it "returns member dashboard data" do
        get "/api/v1/dashboard", headers: headers_member

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["borrowed_books"].first["book_id"]).to eq(book.id)
        expect(json["borrowed_books"].first["title"]).to eq(book.title)
        expect(json["borrowed_books"].first["returned"]).to eq(false)
        expect(json["total_overdue"]).to eq(member.borrowings.overdue.count)
      end
    end

    context "unauthorized user" do
      let(:headers_invalid) { { "Authorization" => "Bearer invalidtoken" } }

      it "returns unauthorized with invalid token" do
        get "/api/v1/dashboard", headers: headers_invalid

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unauthorized")
      end
    end
  end
end
