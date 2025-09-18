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
  scope :available, -> { where(status: :available) }

  # methods
  def loan_duration
    borrowable.item_type.loan_duration_days
  end

  def due_date
    Time.zone.now + loan_duration.days
  end
end
