class Borrowable < ApplicationRecord
  belongs_to :item_type
  has_many :copies, dependent: :destroy
  has_many :borrowings, through: :copies

  validates :title, presence: true
  validates :copies_count, numericality: { greater_than_or_equal_to: 0 }
end
