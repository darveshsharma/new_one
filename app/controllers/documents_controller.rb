class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property
  before_action :set_document, only: [:show, :destroy]

  def create
    @document = @property.documents.build(document_params)
    if @document.save
      redirect_to @property, notice: "Document uploaded successfully."
    else
      redirect_to @property, alert: "Failed to upload document."
    end
  end

  def show
    # Check if user has paid for this document
    access = DocumentAccess.find_by(user: current_user, document: @document)

    if access&.payment_status == 'paid'
      # Allow download
      send_file @document.file_url.path, filename: @document.file_url.filename.to_s, disposition: 'attachment'
    else
      # Calculate amount (1% of property price)
      amount = (@property.price * 0.01).round(2)

      # Redirect to payment page with necessary params
      redirect_to new_payment_path(
        property_id: @property.id,
        document_id: @document.id,
        amount: amount
      ), alert: "Please complete payment of ₹#{amount} to download this document."
    end
  end

  def destroy
    @document.destroy
    redirect_to @property, notice: "Document deleted."
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_document
    @document = @property.documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:document_type, :file_url)
  end
end
