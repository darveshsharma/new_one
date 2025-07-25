class Property < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy

  scope :featured, -> { where(featured: true) }

  has_many_attached :images # user uploads
  has_one_attached :main_image
  has_one_attached :thumbnail

  has_many :documents, dependent: :destroy
  has_many :consultation_requests, dependent: :destroy
  has_one_attached :mutation_document
  has_many_attached :supporting_documents

  validates :title, :property_type, :location, :price, presence: true
  scope :approved, -> { where(approved: true) }

  def images_table_records
    Image.where(property_id: self.id)
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user consultation_requests]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id user_id title description property_type subtype location price dispute_status
      dispute_summary status approved mutation_document title_document aksfard_document
      court_case_document ownership_type total_area jamabandi_year boundaries
      created_at updated_at
    ]
  end
end
