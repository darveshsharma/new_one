class MembershipPaymentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @membership_payment = MembershipPayment.new
  end

  def show
    if current_user&.membership_paid
      flash[:notice] = "You are already a member."
      redirect_to root_path
    end
  end

  def create
    # Implement payment gateway integration logic here

    @membership_payment = current_user.membership_payments.build(membership_payment_params)
    @membership_payment.payment_status = 'success'
    @membership_payment.paid_at = Time.now

    if @membership_payment.save
      current_user.update(membership_status: 'active', membership_paid: true, membership_paid_at: Time.now)
      redirect_to root_path, notice: "Membership activated."
    else
      render :new
    end
  end

  private

  def membership_payment_params
    params.require(:membership_payment).permit(:amount, :payment_gateway, :transaction_id)
  end
end
