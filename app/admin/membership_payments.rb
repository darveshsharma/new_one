ActiveAdmin.register MembershipPayment do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :user_id, :amount, :payment_status, :payment_gateway, :transaction_id, :paid_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :amount, :payment_status, :payment_gateway, :transaction_id, :paid_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
