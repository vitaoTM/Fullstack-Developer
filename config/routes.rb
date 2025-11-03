Rails.application.routes.draw do
  get "profiles/show"
  get "profiles/edit"
  get "profiles/update"
  get "profiles/destroy"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  namespace :admin do
    get "users/index"
    get "users/show"
    get "users/new"
    get "users/create"
    get "users/edit"
    get "users/update"
    get "users/destroy"
    get "dashboard/show"
    get "dashboard", to: "dashboard#show"

    resources :users

    patch "users/:id/toggle_role", to: "users#toggle_role", as: :toggle_user_role

    resources :user_imports, only: [ :new, :create, :show ]
  end

  resource :profile, only: [ :show, :edit, :update, :destroy ]
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "admin/dashboard#show"
  get "up" => "rails/health#show", as: :rails_health_check
end
