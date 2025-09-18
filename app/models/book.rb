class Book < Borrowable
  belongs_to :borrowable

  validates :isbn, presence: true
  validates :author, :genre, presence: true

  delegate :title, :item_type, :copies_count, :copies, :borrowings, to: :borrowable
  
  def self.with_borrowable_data
    joins(:borrowable).includes(:borrowable)
  end
end
