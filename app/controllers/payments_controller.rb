# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property

  def new
    amount = (@property.price * 0.01).round(2) # 1% of property price
    order = Razorpay::Order.create(
      amount: (amount * 100).to_i, # Amount in paise
      currency: 'INR',
      receipt: "prop_doc_#{@property.id}_#{Time.now.to_i}"
    )

    payment = PropertyPayment.create!(
      user: current_user,
      property: @property,
      amount: amount,
      payment_status: 'created',
      razorpay_order_id: order.id
    )

    @razorpay_order_id = order.id
    @amount = amount
    @property_id = @property.id
    @payment = payment
  end

  def verify
    payment = PropertyPayment.find_by(razorpay_order_id: params[:razorpay_order_id])

    if payment.present?
      payment.update!(
        payment_status: 'paid',
        razorpay_payment_id: params[:razorpay_payment_id]
      )

      # (Optional) Send email receipt here

      redirect_to property_path(payment.property), notice: "Payment successful. You can now download documents."
    else
      redirect_to properties_path, alert: "Payment verification failed."
    end
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end
end
