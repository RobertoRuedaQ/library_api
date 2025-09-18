class Book < Borrowable
  validates :isbn, presence: true
  validates :author, :genre, presence: true
end
