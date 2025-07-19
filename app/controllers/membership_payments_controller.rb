class MembershipPaymentsController < ApplicationController
  before_action :authenticate_user!

  def new
    if current_user&.membership_paid
      redirect_to root_path, notice: "You are already a member."
    else
      @membership_payment = MembershipPayment.new
    end
  end

  def create
    amount = 10000 # example ₹100.00 in paise

    order = Razorpay::Order.create(
      amount: amount,
      currency: 'INR',
      receipt: "receipt_#{SecureRandom.hex(5)}",
      payment_capture: 1
    )

    @order_id = order.id
    @membership_payment = current_user.membership_payments.create!(
      amount: amount / 100,
      payment_gateway: "Razorpay",
      payment_status: "pending",
      razorpay_order_id: @order_id
    )

    render :new
  end

  def verify
    payment_id = params[:razorpay_payment_id]
    order_id = params[:razorpay_order_id]
    signature = params[:razorpay_signature]

    begin
      Razorpay::Utility.verify_payment_signature(
        razorpay_order_id: order_id,
        razorpay_payment_id: payment_id,
        razorpay_signature: signature
      )

      membership_payment = MembershipPayment.find_by(razorpay_order_id: order_id)
      membership_payment.update(
        payment_status: "success",
        transaction_id: payment_id,
        paid_at: Time.current
      )

      current_user.update(
        membership_status: "active",
        membership_paid: true,
        membership_paid_at: Time.current
      )

      MembershipMailer.confirmation(current_user).deliver_now

      redirect_to root_path, notice: "Payment successful. Membership activated."
    rescue Razorpay::Errors::SignatureVerificationError
      redirect_to root_path, alert: "Payment verification failed."
    end
  end
  def create_razorpay_order
  Razorpay.setup(Rails.application.credentials.dig(:razorpay, :key_id),
                 Rails.application.credentials.dig(:razorpay, :key_secret))
  order = Razorpay::Order.create(amount: 10000 * 100, currency: 'INR')
  render json: { id: order.id, amount: order.amount }
end

def verify_razorpay_payment
  # Fetch params
  payment_id = params[:razorpay_payment_id]
  order_id = params[:razorpay_order_id]
  signature = params[:razorpay_signature]

  Razorpay.setup(Rails.application.credentials.dig(:razorpay, :key_id),
                 Rails.application.credentials.dig(:razorpay, :key_secret))

  begin
    Razorpay::Utility.verify_payment_signature({
      razorpay_order_id: order_id,
      razorpay_payment_id: payment_id,
      razorpay_signature: signature
    })

    # Save payment record and activate membership
    membership_payment = current_user.membership_payments.create!(
      amount: 10000,
      payment_gateway: 'Razorpay',
      transaction_id: payment_id,
      payment_status: 'success',
      paid_at: Time.now,
      razorpay_order_id: order_id
    )
    current_user.update(membership_status: 'active', membership_paid: true, membership_paid_at: Time.now)

    render json: { success: true }
  rescue Razorpay::SignatureVerificationError => e
    render json: { success: false, error: e.message }
  end
end


  private

  def membership_payment_params
    params.require(:membership_payment).permit(:amount, :payment_gateway, :transaction_id)
  end
end
