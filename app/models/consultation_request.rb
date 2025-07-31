class ConsultationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :property, optional: true

  validates :first_name, :last_name, :email, :phone_number, :description, presence: true



  def full_name
    "#{first_name} #{last_name}"
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user property]
  end

  # Allowlisting attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      user_id
      property_id
      service_type
      summary
      status
      supporting_document
      created_at
      updated_at
    ]
  end

end
