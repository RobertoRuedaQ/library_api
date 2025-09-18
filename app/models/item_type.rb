class ItemType < ApplicationRecord
  has_many :borrowables, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :loan_duration_days, :max_renewals, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
