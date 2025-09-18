class Copy < ApplicationRecord
  belongs_to :borrowable
  has_many :borrowings, dependent: :destroy

  validates :condition, presence: true
  validates :status, presence: true

  enum status: {
    available: 0,
    borrowed: 1,
    maintenance: 2,
    lost: 3,
    damaged: 4
  }
end
