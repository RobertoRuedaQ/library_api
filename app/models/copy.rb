class Copy < ApplicationRecord
  # associations
  belongs_to :borrowable
  has_many :borrowings, dependent: :destroy

  # validations
  validates :condition, presence: true
  validates :status, presence: true

  enum :status, {
    available: 0,
    borrowed: 1,
    maintenance: 2,
    lost: 3,
    damaged: 4
  }

  # scopes
  scope :available, -> {
    left_outer_joins(:borrowings)
      .where(borrowings: { returned_at: nil })
      .or(where.missing(:borrowings))
  }
end
