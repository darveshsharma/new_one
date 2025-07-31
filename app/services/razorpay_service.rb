class RazorpayService
  def initialize
    Razorpay.setup(
      Rails.application.credentials.dig(:razorpay, :key_id),
      Rails.application.credentials.dig(:razorpay, :key_secret)
    )
  end

  def create_order(amount:, receipt:)
    Razorpay::Order.create(
      amount: amount,
      currency: 'INR',
      receipt: receipt,
      payment_capture: 1
    )
  end

  def verify_payment_signature(order_id, payment_id, signature)
    body = "#{order_id}|#{payment_id}"
    expected_signature = OpenSSL::HMAC.hexdigest(
      'SHA256',
      Rails.application.credentials.dig(:razorpay, :key_secret),
      body
    )
    expected_signature == signature
  end
end
