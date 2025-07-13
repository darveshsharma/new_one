class ConsultationRequestsController < ApplicationController
  before_action :set_property, only: [:new, :create]
  before_action :require_active_member

  def index
    @consultation_requests = current_user.consultation_requests
  end

  def show
    @consultation_request = ConsultationRequest.find(params[:id])
    require_owner_of(@consultation_request)
  end

  def new
    @consultation_request = @property.consultation_requests.build
  end

  def create
    @consultation_request = @property.consultation_requests.build(consultation_request_params)
    @consultation_request.user = current_user
    if @consultation_request.save
      redirect_to @property, notice: "Consultation request submitted."
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
    @property = Property.find(params[:property_id])
  end

  def consultation_request_params
    params.require(:consultation_request).permit(:service_type, :summary, :supporting_document, :status)
  end
end
