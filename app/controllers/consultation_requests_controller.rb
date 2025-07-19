class ConsultationRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_active_member
  before_action :set_property, only: [:new, :create], if: -> { params[:property_id].present? }

  def index
    @consultation_requests = current_user.consultation_requests
  end

  def show
    @consultation_request = ConsultationRequest.find(params[:id])
    require_owner_of(@consultation_request)
  end

  def new
    if @property
      @consultation_request = @property.consultation_requests.build
    else
      @consultation_request = ConsultationRequest.new
    end
  end

  def create
    if @property
      @consultation_request = @property.consultation_requests.build(consultation_request_params)
    else
      @consultation_request = ConsultationRequest.new(consultation_request_params)
    end

    @consultation_request.user = current_user

    if @consultation_request.save
      redirect_to @property || consultation_requests_path, notice: "Consultation request submitted."
    else
      render :new
    end
  end

  def update
    @consultation_request = ConsultationRequest.find(params[:id])
    require_owner_of(@consultation_request)

    if @consultation_request.update(consultation_request_params)
      redirect_to @consultation_request, notice: "Consultation request updated."
    else
      render :edit
    end
  end

  private

  def set_property
    @property = Property.find_by(id: params[:property_id])
  end

  def consultation_request_params
    params.require(:consultation_request).permit(:service_type, :summary, :supporting_document, :status, :property_id)
  end
end
