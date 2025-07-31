class ConsultationMailer < ApplicationMailer
  default from: 'anamikakaushik269@gmail.com'

  def new_consultation(consultation_request)
    @consultation = consultation_request
    mail(
      to: "anamikakaushik269@gmail.com", # replace with your destination email
      subject: "New Consultation Request from #{@consultation.full_name}"
    )
  end
end
