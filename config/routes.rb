CloisterSpaceServer::Application.routes.draw do

  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  resources :sessions

  get "sign_up" => "users#new", :as => "sign_up"
  resources :users

  resources :games do
    match 'tileInstances/place/:id' => 'tileInstances#update'
    match 'tileInstances/:status' => 'tileInstances#index'

    match 'next' => 'games#next'
    match 'move/:num' => 'games#move'
  end

  root :to => 'games#index'
end
