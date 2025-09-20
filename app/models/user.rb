class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :borrowings, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, :last_name, presence: true
  validates :birth_date, presence: true

  # Scopes
  scope :with_overdue_books, -> { joins(:borrowings).merge(Borrowing.overdue).distinct }

  # Instance Methods
  def full_name
    "#{name} #{last_name}"
  end

  def has_permission?(resource, action)
    roles.joins(:permissions).exists?(
      permissions: { resource: resource, action: action }
    )
  end
end
