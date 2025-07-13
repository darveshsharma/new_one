class PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :edit, :update, :destroy]
  before_action :require_active_member, only: [:new, :create, :edit, :update, :destroy]
  before_action only: [:edit, :update, :destroy] do
    require_owner_of(@property)
  end

  def index
    @properties = Property.all
  end

  def show
  end

  def new
    @property = current_user.properties.build
  end

  def create
    @property = current_user.properties.build(property_params)
    if @property.save
      redirect_to @property, notice: "Property created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: "Property updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path, notice: "Property deleted."
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def property_params
    params.require(:property).permit(
      :title, :description, :property_type, :subtype, :location, :price,
      :dispute_status, :dispute_summary, :status, :approved, :ownership_type,
      :total_area, :jamabandi_year, :boundaries,
      :mutation_document, :title_document, :aksfard_document, :court_case_document,
      :main_image, :thumbnail, images: []
    )
  end
end
