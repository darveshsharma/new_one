class User < ApplicationRecord
  # Associations
  has_many :consultation_requests
  has_many :properties, dependent: :destroy
  has_many :membership_payments

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { owner: 0, dealer: 1, lawyer: 2, buyer: 3, admin: 4 }

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :owner
  end

  def member?
    self.member
  end

  def active_member?
    membership_paid? || member?
  end

  def admin?
    role == 'admin'
  end

  def self.ransackable_associations(auth_object = nil)
    %w[properties consultation_requests]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id email role member membership_paid membership_paid_at
      created_at updated_at
    ]
  end
end
