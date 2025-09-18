Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do

      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      
      resources :books do
        resources :copies, except: [:show]
      end
      
      resources :magazines do
        resources :copies, except: [:show]
      end
      
      resources :dvds do
        resources :copies, except: [:show]
      end
      
      resources :copies, only: [:show] do
        member do
          post :borrow
          patch :return
        end
      end
      
      resources :borrowings do
        member do
          patch :renew
          patch :return
        end
      end
      
      resources :users, except: [:new, :edit]
      
      get 'search/borrowables', to: 'search#borrowables'
      get 'search/available_copies', to: 'search#available_copies'
    end
  end
end
