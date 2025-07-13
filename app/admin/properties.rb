# app/admin/properties.rb

ActiveAdmin.register Property do
  permit_params :user_id, :title, :description, :property_type, :subtype, :location, :price, :dispute_status,
                :dispute_summary, :status, :approved, :mutation_document, :title_document, :aksfard_document,
                :court_case_document, :ownership_type, :total_area, :jamabandi_year, :boundaries

  # Filters
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

  # Index page
  index do
    selectable_column
    id_column
    column :user
    column :title
    column :property_type
    column :subtype
    column :location
    column :price
    column :dispute_status
    column :status
    column :approved
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
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
      row :mutation_document
      row :title_document
      row :aksfard_document
      row :court_case_document
      row :ownership_type
      row :total_area
      row :jamabandi_year
      row :boundaries
      row :created_at
      row :updated_at
    end
  end

  # Form page
  form do |f|
    f.inputs do
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
      f.input :mutation_document
      f.input :title_document
      f.input :aksfard_document
      f.input :court_case_document
      f.input :ownership_type
      f.input :total_area
      f.input :jamabandi_year
      f.input :boundaries
    end
    f.actions
  end
end
