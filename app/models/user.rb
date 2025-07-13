class User < ApplicationRecord
  # Associations
  has_many :consultation_requests
  has_many :properties, dependent: :destroy

  # Devise modules for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

   enum role: { member: 0, owner: 1, dealer: 2, admin: 3 }

  # Default role before creation
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :owner
  end

  # Membership status helpers
  def active_member?
    membership_paid && membership_status == 'active'
  end

  def admin?
    role == 'admin'
  end
    def member?
    role == "member"
  end

  def member?
    owner? || dealer?
  end

  # Ransack configurations (for ActiveAdmin or filters)
  def self.ransackable_associations(auth_object = nil)
    %w[properties consultation_requests]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      email
      role
      membership_status
      membership_paid
      membership_paid_at
      created_at
      updated_at
    ]
  end
end
