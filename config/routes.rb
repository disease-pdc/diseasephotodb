require 'sidekiq/web'

class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find request.session[:user_id]
    user && user.admin?
  end
end

Rails.application.routes.draw do
  root "home#index"
  
  mount Sidekiq::Web => '/sidekiq', :constraints => AdminConstraint.new
  
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
  post '/images/metadata', to: 'images#metadata'
  resources :grading_sets
  get '/grading_sets/:id/data', to: 'grading_sets#data'
  post '/grading_sets/:id/adduser', to: 'grading_sets#adduser'
  post '/grading_sets/:id/removeuser', to: 'grading_sets#removeuser'
  post '/grading_sets/:id/removeimage', to: 'grading_sets#removeimage'

end
