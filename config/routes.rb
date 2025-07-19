Rails.application.routes.draw do
root 'home#index'
devise_scope :user do
  get 'users/sign_out', to: 'devise/sessions#destroy'
end
# Devise routes for users and admin_users
devise_for :users
devise_for :admin_users, ActiveAdmin::Devise.config

# ActiveAdmin routes
ActiveAdmin.routes(self)

# Membership payments
resources :membership_payments, only: [:new, :create]
post 'create_razorpay_order', to: 'membership_payments#create_razorpay_order'
post 'verify_razorpay_payment', to: 'membership_payments#verify_razorpay_payment'


# Properties and nested resources
resources :properties do
  resources :documents, only: [:create, :destroy]
  resources :consultation_requests, only: [:new, :create]
  resources :document_accesses, only: [:create]
end


# Consultation requests routes
resources :consultation_requests, only: [:index, :show, :update]

# Home route
get "home/index"


end
