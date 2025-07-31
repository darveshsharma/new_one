require 'ostruct'

class ConsultationRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_active_member

  def new
    @consultation_request = OpenStruct.new
  end

  def create
    @consultation_request = OpenStruct.new(consultation_request_params)

    ConsultationMailer.new_consultation(@consultation_request).deliver_now
    flash[:notice] = "Your consultation inquiry has been sent successfully!"
    redirect_to new_consultation_request_path
    end

  private

  def consultation_request_params
    params.require(:consultation_request).permit(:first_name, :last_name, :email, :phone_number, :message).tap do |whitelisted|
      whitelisted[:full_name] = "#{whitelisted[:first_name]} #{whitelisted[:last_name]}"
    end
  end
end
