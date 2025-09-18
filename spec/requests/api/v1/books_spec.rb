require "rails_helper"

RSpec.describe "Api::V1::Books", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let!(:book1) { create(:book, title: "Harry Potter", author: "J.K. Rowling", genre: "Fantasy") }
  let!(:book2) { create(:book, title: "Sherlock Holmes", author: "Arthur Conan Doyle", genre: "Mystery") }
  let(:headers_librarian) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: librarian.id)}" } }
  let(:headers_member) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: member.id)}" } }

  describe "GET /books" do
    it "returns paginated list of books" do
      get "/api/v1/books", headers: headers_member
      expect(response).to have_http_status(:ok)

      books = JSON.parse(response.body)
      expect(books.size).to be >= 1
    end

    it "filters by title" do
      get "/api/v1/books", params: { title: "Harry" }, headers: headers_member
      books = JSON.parse(response.body)
      expect(books.map { |b| b["title"] }).to include("Harry Potter")
      expect(books.map { |b| b["title"] }).not_to include("Sherlock Holmes")
    end

    it "filters by author" do
      get "/api/v1/books", params: { author: "Doyle" }, headers: headers_member
      books = JSON.parse(response.body)
      expect(books.first["author"]).to eq("Arthur Conan Doyle")
    end

    it "filters by genre" do
      get "/api/v1/books", params: { genre: "Fantasy" }, headers: headers_member
      books = JSON.parse(response.body)
      expect(books.first["genre"]).to eq("Fantasy")
    end

    it "filters by multiple fields" do
      get "/api/v1/books", params: { title: "Sherlock", author: "Doyle" }, headers: headers_member
      books = JSON.parse(response.body)
      expect(books.map { |b| b["title"] }).to eq([ "Sherlock Holmes" ])
    end
  end

  describe "POST /books" do
    let(:valid_params) do
      { book: { title: "New Book", author: "Author X", genre: "Tech", isbn: "444", item_type_id: book1.item_type.id } }
    end

    it "allows librarian to create a book" do
      post "/api/v1/books", params: valid_params, headers: headers_librarian
      expect(response).to have_http_status(:ok)
      expect(Book.last.title).to eq("New Book")
    end

    it "forbids member to create a book" do
      post "/api/v1/books", params: valid_params, headers: headers_member
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PUT /books/:id" do
    it "allows librarian to update a book" do
      put "/api/v1/books/#{book1.id}", params: { book: { title: "Updated Title" } }, headers: headers_librarian
      expect(response).to have_http_status(:ok)
      expect(book1.reload.title).to eq("Updated Title")
    end
  end

  describe "DELETE /books/:id" do
    it "allows librarian to delete a book" do
      delete "/api/v1/books/#{book1.id}", headers: headers_librarian
      expect(response).to have_http_status(:no_content)
      expect(Book.exists?(book1.id)).to be_falsey
    end
  end
end
