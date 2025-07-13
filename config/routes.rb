Rails.application.routes.draw do
root 'home#index'

# Devise routes for users and admin_users
devise_for :users
devise_for :admin_users, ActiveAdmin::Devise.config

# ActiveAdmin routes
ActiveAdmin.routes(self)

# Membership payments
resources :membership_payments, only: [:new, :create, :show]
get '/membership', to: 'membership_payments#new', as: :membership

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
