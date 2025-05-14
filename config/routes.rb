Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  namespace :admin do
    resources :dashboard, only: [ :index ]
    resources :users, only: [ :show, :destroy, :edit, :update, :index, :new, :create ] do
      member do
        delete :delete_profile_image
      end
    end
    resources :roles, only: [ :index, :new, :create, :show, :update, :edit ] do
      resources :user_roles, only: [ :create, :new, :destroy ], module: :roles
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "admin/dashboard#index"
end
