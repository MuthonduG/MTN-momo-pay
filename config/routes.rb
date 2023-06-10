Rails.application.routes.draw do
  resources :momopays
  resources :users

  post 'create_user', to: 'momopays#create_user'
  post 'create_key', to: 'momopays#create_apikey'
  get 'get_user', to: 'momopays#get_user'
  post 'access_token', to: 'momopays#generate_access_token'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
