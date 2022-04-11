Rails.application.routes.draw do
  root "home#index"
  
  # Sessions
  get '/signin', to: 'sessions#new'
  post '/signin', to: 'sessions#send_login'
  get '/signin/token', to: 'sessions#create'
  get '/signout', to: 'sessions#delete'

  # Dashboard
  get '/dashboard', to: 'dashboard#index'

  # Grading
  get '/grade/:grading_set_id', to: 'grading#index'
  get '/grade/:grading_set_id/:user_grading_set_image_id', to: 'grading#show'
  post '/grade/:grading_set_id', to: 'grading#grade'
  post '/grade/::grading_set_id/complete', to: 'grading#complete'

  resources :image_sources
  get '/metadata', to: 'metadata#index'
  post '/metadata', to: 'metadata#update'
  resources :users
  resources :images
  post '/images/addtogradingset', to: 'images#addtogradingset'
  resources :grading_sets

end
