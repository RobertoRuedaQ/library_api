class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :name, :resource, :action, presence: true
  validates :resource, uniqueness: { scope: :action }

  enum action: {
    create: 0,
    read: 1,
    update: 2,
    delete: 3,
    manage: 4
  }
end
