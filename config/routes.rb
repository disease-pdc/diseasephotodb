Rails.application.routes.draw do
  root "home#index"
  
  # Sessions
  get '/signin', to: 'sessions#new'
  post '/signin', to: 'sessions#send_login'
  get '/signin/token', to: 'sessions#create'
  get '/signout', to: 'sessions#delete'

  
end
