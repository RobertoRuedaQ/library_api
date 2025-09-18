class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :copy

  validates :borrowed_at, :due_at, presence: true
  validates :renewal_count, numericality: { greater_than_or_equal_to: 0 }
  
  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where('due_at < ?', Time.current) }
  scope :returned, -> { where.not(returned_at: nil) }
  
  def overdue?
    returned_at.nil? && due_at < Time.current
  end
  
  def active?
    returned_at.nil?
  end
  
  def can_renew?
    return false unless active?
    return false if overdue?
    
    max_renewals = copy.borrowable.item_type.max_renewals
    renewal_count < max_renewals
  end
  
  def return_item!
    update!(returned_at: Time.current)
    copy.update!(status: :available)
  end
  
  def renew!
    return false unless can_renew?
    
    loan_duration = copy.borrowable.item_type.loan_duration_days
    new_due_date = due_at + loan_duration.days
    
    update!(
      due_at: new_due_date
    )
  end
end
