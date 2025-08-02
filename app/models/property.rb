class Property < ApplicationRecord
  attr_accessor :main_image_url, :thumbnail_url
  belongs_to :user
  has_many :images, dependent: :destroy

  # with_options unless: :persisted_document_attached? do
  #   validates :title_document_files, presence: { message: "must be attached" }
  #   validates :mutation_document_files, presence: { message: "must be attached" }
  #   validates :aksfard_document_files, presence: { message: "must be attached" }
  #   validates :court_case_document_files, presence: { message: "must be attached" }
  # end


  scope :featured, -> { where(featured: true) }

  has_many_attached :images # user uploads
  has_one_attached :main_image
  has_one_attached :thumbnail

  has_many :documents, dependent: :destroy
  has_many :consultation_requests, dependent: :destroy
#   has_one_attached :mutation_document
#   has_many_attached :title_document_files
# has_one_attached :aksfard_document
# has_one_attached :court_case_document

has_many_attached :title_document_files
  has_many_attached :mutation_document_files
  has_many_attached :aksfard_document_files
  has_many_attached :court_case_document_files

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

  private 
  def persisted_document_attached?
    return false unless persisted?

    title_document_files.attached? &&
      mutation_document_files.attached? &&
      aksfard_document_files.attached? &&
      court_case_document_files.attached?
  end

end
