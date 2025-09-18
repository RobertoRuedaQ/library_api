class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :copy

  validates :borrowed_at, :due_at, presence: true
  validates :renewal_count, numericality: { greater_than_or_equal_to: 0 }

  scope :for_user, ->(user) { where(user: user) }
  scope :active_for_user, ->(user) { for_user(user).active }
  scope :overdue_for_user, ->(user) { for_user(user).overdue }

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
    return false if returned_at.present?

    transaction do
      update!(returned_at: Time.zone.now)
      copy.update!(status: :available)
    end

      true
    rescue ActiveRecord::RecordInvalid
      false
  end

  def renew!
    return false unless can_renew?

    transaction do
      update!(
        due_at: due_at + copy.loan_duration.days,
        renewal_count: renewal_count + 1
      )
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
