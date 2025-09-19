Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   "login",  to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      resource :dashboard, only: [ :show ], controller: "dashboard"

      resources :books do
        resources :copies, only: [ :index, :create ]
      end

      resources :copies, only: [ :show, :update, :destroy ]

      resources :borrowings, only: [ :index, :create ] do
        member do
          patch :renew
          patch :return
        end
      end

      resources :users, except: [ :new, :edit ]
    end
  end
end
