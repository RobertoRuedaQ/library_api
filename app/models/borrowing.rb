class Borrowing < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :copy

  # validations
  validates :borrowed_at, :due_at, presence: true
  validates :due_at, comparison: { greater_than_or_equal_to: :borrowed_at }
  validates :renewal_count, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :active_for_user, ->(user) { for_user(user).active }
  scope :overdue_for_user, ->(user) { for_user(user).overdue }
  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where("due_at < ?", Time.current) }
  scope :due_today, -> { active.where(due_at: Time.zone.today.all_day) }

  # Instance Methods
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
