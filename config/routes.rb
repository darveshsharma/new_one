Rails.application.routes.draw do
  get 'profiles/edit'
  get 'profiles/update'
  root 'home#index'

  # Devise sign-out route override
  devise_scope :user do
    get 'users/sign_out', to: 'devise/sessions#destroy'
  end

  # Devise routes for users and admin_users
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config

  # ActiveAdmin routes
  ActiveAdmin.routes(self)

  # Membership payments
  resources :membership_payments, only: [:new, :create, :show]
  post 'create_razorpay_order', to: 'membership_payments#create_razorpay_order'
  post 'verify_razorpay_payment', to: 'membership_payments#verify_razorpay_payment'

  # Properties and nested resources
  resources :properties do
member do
    get :download_documents
  end

    resources :documents, only: [:create, :destroy]
    resources :consultation_requests, only: [:new, :create]
    resources :document_accesses, only: [:new, :create]
     resources :payments do
    post 'verify', on: :member  # will need payment ID in route
  end
  end

  # Global consultation requests
  resources :consultation_requests, only: [:new, :create]
  # config/routes.rb
resource :profile, only: [:edit, :update]


  # Home
  get "home/index"
end
