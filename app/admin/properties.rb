ActiveAdmin.register Property do
  permit_params :user_id, :title, :description, :property_type, :subtype, :location, :price,
                :dispute_status, :dispute_summary, :status, :approved,
                :ownership_type, :total_area, :jamabandi_year, :boundaries,
                :main_image_url, :thumbnail_url,
                :main_image, :thumbnail,
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

  form html: { multipart: true } do |f|
    f.semantic_errors

    f.inputs 'Basic Details' do
      f.input :user
      f.input :title
      f.input :description
      f.input :property_type
      f.input :subtype
      f.input :location
      f.input :price
      f.input :dispute_status
      f.input :dispute_summary
      f.input :status
      f.input :approved
      f.input :ownership_type
      f.input :total_area
      f.input :jamabandi_year
      f.input :boundaries
    end

    f.inputs 'Main Image' do
      if f.object.main_image.attached?
        div do
          image_tag url_for(f.object.main_image), style: 'max-width: 200px;'
        end
      end
      f.input :main_image, as: :file
      f.input :main_image_url, label: "Main Image URL (optional, overrides file if provided)"
    end

    f.inputs 'Thumbnail' do
      if f.object.thumbnail.attached?
        div do
          image_tag url_for(f.object.thumbnail), style: 'max-width: 200px;'
        end
      end
      f.input :thumbnail, as: :file
      f.input :thumbnail_url, label: "Thumbnail URL (optional, overrides file if provided)"
    end

    f.inputs 'Gallery Images' do
      if f.object.images.attached?
        f.object.images.each do |img|
          div do
            image_tag url_for(img), style: 'max-width: 150px; margin: 5px;'
          end
        end
      end
      f.input :images, as: :file, input_html: { multiple: true }
    end

    f.inputs 'Documents' do
      f.input :title_document_files, as: :file, input_html: { multiple: true }
      f.input :mutation_document_files, as: :file, input_html: { multiple: true }
      f.input :aksfard_document_files, as: :file, input_html: { multiple: true }
      f.input :court_case_document_files, as: :file, input_html: { multiple: true }
      f.input :supporting_documents, as: :file, input_html: { multiple: true }
    end

    f.actions
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
