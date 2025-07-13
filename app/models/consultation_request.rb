class ConsultationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :property, optional: true

  has_one_attached :mutation_document
has_many_attached :supporting_documents


  validates :service_type, :summary, presence: true

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
