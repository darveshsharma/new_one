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
    amount = 10_000 # ₹10,000
    receipt = "membership_#{SecureRandom.hex(5)}"

    razorpay_service = RazorpayService.new
    order = razorpay_service.create_order(amount: amount, receipt: receipt)
    @order_id = order.id

    @membership_payment = current_user.membership_payments.create!(
      amount: amount,
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
      razorpay_service = RazorpayService.new
      is_valid = razorpay_service.verify_payment_signature(order_id, payment_id, signature)

      if is_valid
        membership_payment = MembershipPayment.find_by(razorpay_order_id: order_id)
        membership_payment.update!(
          payment_status: "success",
          transaction_id: payment_id,
          paid_at: Time.current
        )

        current_user.update!(
          membership_status: "active",
          membership_paid: true,
          membership_paid_at: Time.current,
          member: true
        )

        MembershipEmailJob.perform_later(current_user.id, membership_payment.id)

        redirect_to root_path, notice: "Payment successful. Membership activated."
      else
        redirect_to root_path, alert: "Payment verification failed."
      end
    rescue => e
      Rails.logger.error("Payment verification error: #{e.message}")
      redirect_to root_path, alert: "Payment verification error occurred."
    end
  end

  def create_razorpay_order
    amount = 10_000
    receipt = "membership_#{SecureRandom.hex(5)}"

    razorpay_service = RazorpayService.new
    order = razorpay_service.create_order(amount: amount, receipt: receipt)

    render json: { id: order.id, amount: order.amount }
  end

  def verify_razorpay_payment
    data = JSON.parse(request.body.read).with_indifferent_access
    payment_id = data[:razorpay_payment_id]
    order_id = data[:razorpay_order_id]
    signature = data[:razorpay_signature]

    begin
      razorpay_service = RazorpayService.new
      is_valid = razorpay_service.verify_payment_signature(order_id, payment_id, signature)

      if is_valid
        membership_payment = current_user.membership_payments.create!(
          amount: 10_000,
          payment_gateway: 'Razorpay',
          transaction_id: payment_id,
          payment_status: 'success',
          paid_at: Time.current,
          razorpay_order_id: order_id
        )

        current_user.update!(
          membership_status: 'active',
          membership_paid: true,
          membership_paid_at: Time.current,
          member: true
        )

        MembershipEmailJob.perform_later(current_user.id, membership_payment.id)

        render json: { success: true }
      else
        render json: { success: false, error: "Invalid signature" }
      end
    rescue => e
      Rails.logger.error "Payment verification failed: #{e.message}"
      render json: { success: false, error: e.message }
    end
  end

  def show 
  end

  private

  def membership_payment_params
    params.require(:membership_payment).permit(:amount, :payment_gateway, :transaction_id)
  end
end
