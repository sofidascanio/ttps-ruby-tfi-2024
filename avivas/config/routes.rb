Rails.application.routes.draw do
  resources :sales
  resources :categories
  resources :products
  resources :users 

  #devise_for :users, path: 'auth', skip: [:all] 
  devise_for :users, path: 'auth'

  # devise_scope :user do
  #   # solo login y editar perfil
  #   get 'auth/sign_in', to: 'devise/sessions#new', as: :new_user_session
  #   post 'auth/sign_in', to: 'devise/sessions#create', as: :user_session
  #   delete 'auth/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session

  #   get 'auth/edit', to: 'devise/registrations#edit', as: :edit_user_registration
  #   patch 'auth', to: 'devise/registrations#update', as: :user_registration
  #   put 'auth', to: 'devise/registrations#update' 
  # end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root to: "products#index"
end
