CloisterSpaceServer::Application.routes.draw do

  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  resources :sessions

  get "sign_up" => "users#new", :as => "sign_up"
  resources :users

  match 'tiles' => 'tiles#index'
  match 'edges' => 'edges#index'

  resources :games do
    match 'roads' => 'roads#index'
    match 'cloisters' => 'cloisters#index'
    match 'cities' => 'cities#index'
    match 'farms' => 'farms#index'

    match 'tileInstances/place/:id' => 'tileInstances#update'
    match 'tileInstances/:status' => 'tileInstances#index'

    match 'next' => 'games#next'
  end

  root :to => 'games#index'
end
