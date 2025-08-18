ActiveAdmin.register Property do
  permit_params :user_id, :title, :description, :property_type, :subtype, :location, :price,
                :dispute_status, :dispute_summary, :status, :approved,
                :ownership_type, :total_area, :jamabandi_year, :boundaries,
                :main_image_url, :thumbnail_url,
                :main_image, :thumbnail,:featured,
                images: [], title_document_files: [], mutation_document_files: [],
                aksfard_document_files: [], court_case_document_files: [], supporting_documents: []

  filter :user
filter :title
filter :property_type
filter :subtype
filter :location
filter :price
filter :dispute_status
filter :status
filter :approved
filter :ownership_type
filter :jamabandi_year
filter :created_at
filter :updated_at



form html: { multipart: true, class: "property-form" } do |f|
  f.semantic_errors

  f.inputs '🏠 Basic Property Details' do
    f.input :user, as: :select,
                   collection: User.all.map { |u| [u.email, u.id] },
                   prompt: "Select User by Email"
  
    f.input :title, placeholder: "e.g., Luxury Villa in Gurgaon"
    f.input :description, as: :text,
                          input_html: { rows: 5, placeholder: "Enter property description..." }
  
    # Dropdown for Property Type
    f.input :property_type, as: :select,
                            collection: ["Residential", "Commercial", "Agricultural", "Industrial"],
                            include_blank: "Select Property Type"
  
    # Dropdown for Subtype
    f.input :subtype, as: :select,
                      collection: ["Plot", "Flat/Apartment", "Villa", "Shop", "Office", "Farmhouse"],
                      include_blank: "Select Subtype"
  
    f.input :location, placeholder: "e.g., DLF Phase 2, Gurgaon"
    f.input :price, label: "Price (INR)", placeholder: "e.g., 2,50,00,000"
  
    # Dropdown for Ownership Type
    f.input :ownership_type, as: :select,
                             collection: ["Freehold", "Leasehold", "Power of Attorney", "Co-operative"],
                             include_blank: "Select Ownership Type"
  
    f.input :total_area, placeholder: "e.g., 350 sq yards"
  
    # Dropdown for Jamabandi Year (dynamic)
    f.input :jamabandi_year, as: :select,
                             collection: (2000..Time.current.year).to_a.reverse,
                             include_blank: "Select Jamabandi Year"
  
    f.input :boundaries, as: :text,
                         input_html: { rows: 3, placeholder: "North: Road, South: Park..." }
  end
  
  # === Legal & Status ===
  f.inputs '⚖️ Legal & Approval Details' do
    f.input :dispute_status, label: "Dispute Status"
    f.input :dispute_summary, as: :text, placeholder: "Short summary of legal issues..."
    f.input :status, as: :select, collection: ["Available", "Sold", "Under Dispute"], include_blank: "Select Status"
    f.input :approved, label: "Approved for Listing"
    f.input :featured, label: "Featured Property"
  end

  # === Main Image ===
  f.inputs '📸 Main Image' do
    if f.object.main_image.attached?
      div style: "margin-bottom: 10px;" do
        image_tag url_for(f.object.main_image), style: 'max-width: 250px; border: 1px solid #ddd; border-radius: 8px; padding: 5px;'
      end
    end
    f.input :main_image, as: :file, label: "Upload Main Image"
    f.input :main_image_url, label: "Main Image URL (optional)"
  end

  # === Thumbnail ===
  f.inputs '🖼️ Thumbnail' do
    if f.object.thumbnail.attached?
      div style: "margin-bottom: 10px;" do
        image_tag url_for(f.object.thumbnail), style: 'max-width: 150px; border: 1px solid #ddd; border-radius: 8px; padding: 5px;'
      end
    end
    f.input :thumbnail, as: :file, label: "Upload Thumbnail"
    f.input :thumbnail_url, label: "Thumbnail URL (optional)"
  end

  # === Gallery ===
  f.inputs '📷 Gallery Images' do
    if f.object.images.attached?
      div style: "display: flex; flex-wrap: wrap;" do
        f.object.images.each do |img|
          div style: "margin: 5px;" do
            image_tag url_for(img), style: 'max-width: 120px; border: 1px solid #eee; border-radius: 6px;'
          end
        end
      end
    end
    f.input :images, as: :file, input_html: { multiple: true }, label: "Upload Multiple Images"
  end

  # === Documents ===
  f.inputs '📑 Property Documents' do
    f.input :title_document_files, as: :file, input_html: { multiple: true }, label: "Title Documents"
    f.input :mutation_document_files, as: :file, input_html: { multiple: true }, label: "Mutation Papers"
    f.input :aksfard_document_files, as: :file, input_html: { multiple: true }, label: "Aks Fard / Land Records"
    f.input :court_case_document_files, as: :file, input_html: { multiple: true }, label: "Court Case Files"
    f.input :supporting_documents, as: :file, input_html: { multiple: true }, label: "Other Supporting Docs"
  end

  f.actions do
    f.action :submit, label: "💾 Save Property", button_html: { class: "btn-primary" }
    f.cancel_link
  end
end

  show do
    attributes_table do
      row :user
      row :title
      row :description
      row :property_type
      row :subtype
      row :location
      row :price
      row :dispute_status
      row :dispute_summary
      row :status
      row :approved
      row :ownership_type
      row :total_area
      row :jamabandi_year
      row :boundaries

      row :main_image do |property|
        if property.main_image.attached?
          image_tag url_for(property.main_image), style: 'max-width: 200px;'
        end
      end

      row :thumbnail do |property|
        if property.thumbnail.attached?
          image_tag url_for(property.thumbnail), style: 'max-width: 200px;'
        end
      end

      row :images do |property|
        property.images.map do |img|
          image_tag url_for(img), style: 'max-width: 150px; margin: 5px;'
        end.join.html_safe
      end

      row :title_document_files do |property|
        property.title_document_files.map(&:filename).join(', ')
      end
      row :mutation_document_files do |property|
        property.mutation_document_files.map(&:filename).join(', ')
      end
      row :aksfard_document_files do |property|
        property.aksfard_document_files.map(&:filename).join(', ')
      end
      row :court_case_document_files do |property|
        property.court_case_document_files.map(&:filename).join(', ')
      end
      row :supporting_documents do |property|
        property.supporting_documents.map(&:filename).join(', ')
      end
    end
  end

  controller do
    def update
      # Load the existing object
      @property = Property.find(params[:id])

      # Attach images from URL if present
      if params[:property][:main_image_url].present?
        @property.main_image.attach(io: URI.open(params[:property][:main_image_url]), filename: 'main_image.jpg')
      elsif params[:property][:main_image].present?
        @property.main_image.attach(params[:property][:main_image])
      end

      if params[:property][:thumbnail_url].present?
        @property.thumbnail.attach(io: URI.open(params[:property][:thumbnail_url]), filename: 'thumbnail.jpg')
      elsif params[:property][:thumbnail].present?
        @property.thumbnail.attach(params[:property][:thumbnail])
      end

      # Proceed with standard update
      super
    end

    def create
      super do |success, _failure|
        if params[:property][:main_image_url].present?
          resource.main_image.attach(io: URI.open(params[:property][:main_image_url]), filename: 'main_image.jpg')
        end

        if params[:property][:thumbnail_url].present?
          resource.thumbnail.attach(io: URI.open(params[:property][:thumbnail_url]), filename: 'thumbnail.jpg')
        end
      end
    end
  end
end
