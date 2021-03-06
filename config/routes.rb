Rails.application.routes.draw do

  devise_for :users
  root to: 'pages#home'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :cars, only: [:index]
      resources :rentals, only: [:index]
      resources :rental_modifications, only: [:index]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
