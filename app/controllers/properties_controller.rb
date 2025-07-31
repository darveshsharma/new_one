require 'zip'

class PropertiesController < ApplicationController
  layout 'application'

  before_action :set_property, only: [
    :show, :edit, :update, :destroy,
    :initiate_payment, :download_documents, :verify_payment
  ]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :require_active_member, only: [:new, :create, :edit, :update, :destroy]

  def index
    @properties = Property.all
  end

  def show
    @has_paid = current_user && PropertyPayment.exists?(
      user: current_user,
      property: @property,
      payment_status: 'paid'
    )
  end

  def new
    @property = current_user.properties.build
  end

  def create
    @property = current_user.properties.build(property_params)
    if @property.save
      attach_uploaded_files
      redirect_to @property, notice: "Property created successfully."
    else
      render :new
    end
  end

  def edit
    unless current_user == @property.user || current_user.admin?
      redirect_to property_path(@property), alert: "You are not authorized to edit this property."
    end
  end

  def update
    unless current_user == @property.user || current_user.admin?
      redirect_to property_path(@property), alert: "You are not authorized to update this property."
      return
    end

    if @property.update(property_params.except(*file_field_keys))
      attach_uploaded_files
      redirect_to @property, notice: "Property updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path, notice: "Property deleted."
  end

  def initiate_payment
    amount = (@property.price.to_f * 0.01).round(2)
    razorpay_order = RazorpayService.create_payment_order(amount, @property.id, current_user.id)

    render json: {
      razorpay_order_id: razorpay_order.id,
      amount: razorpay_order.amount,
      currency: razorpay_order.currency,
      property_id: @property.id,
      user_id: current_user.id
    }
  end

  def verify_payment
    payment_id = params[:razorpay_payment_id]
    order_id   = params[:razorpay_order_id]
    signature  = params[:razorpay_signature]

    generated_signature = OpenSSL::HMAC.hexdigest(
      'SHA256',
      ENV['RAZORPAY_KEY_SECRET'],
      "#{order_id}|#{payment_id}"
    )

    if signature == generated_signature
      PropertyPayment.create!(
        user: current_user,
        property: @property,
        amount: (@property.price.to_f * 0.01).round(2),
        razorpay_payment_id: payment_id,
        razorpay_order_id: order_id,
        payment_status: 'paid'
      )

      render json: { success: true, message: "Payment verified. Documents ready to download." }
    else
      render json: { success: false, message: "Payment verification failed." }, status: :unauthorized
    end
  end

  def download_documents
    unless current_user && PropertyPayment.exists?(user: current_user, property: @property, payment_status: 'paid')
      redirect_to property_path(@property), alert: "Please pay to access documents."
      return
    end

    files = []
    files += @property.title_document_files if @property.title_document_files.attached?
    files += @property.mutation_document_files if @property.mutation_document_files.attached?
    files += @property.aksfard_document_files if @property.aksfard_document_files.attached?
    files += @property.court_case_document_files if @property.court_case_document_files.attached?
    files += @property.supporting_documents if @property.supporting_documents.attached?

    if files.empty?
      redirect_to property_path(@property), alert: "No documents found to download."
      return
    end

    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      files.each do |file|
        zos.put_next_entry(file.filename.to_s)
        zos.write file.download
      end
    end

    compressed_filestream.rewind
    send_data compressed_filestream.read, filename: "property_documents.zip", type: 'application/zip'
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def file_field_keys
    [
      :images, :main_image, :thumbnail,
      :title_document_files, :mutation_document_files,
      :aksfard_document_files, :court_case_document_files,
      :supporting_documents
    ]
  end

  def property_params
  allowed = [
    :title, :description, :property_type, :subtype,
    :location, :price, :dispute_status, :dispute_summary,
    :ownership_type, :total_area, :jamabandi_year, :boundaries,
    :main_image, :main_image_url, :thumbnail, :thumbnail_url,
    images: []
  ]

  # Merge static file fields if you're using file_field_keys helper
  allowed += file_field_keys if respond_to?(:file_field_keys)

  # Allow status and approved only for admin
  allowed += [:status, :approved] if current_user.admin?

  params.require(:property).permit(*allowed).merge(user_id: current_user.id)
end


  def attach_uploaded_files
    file_field_keys.each do |field|
      if params[:property][field].present?
        Array.wrap(params[:property][field]).each do |file|
          @property.send(field).attach(file)
        end
      end
    end
  end
end
