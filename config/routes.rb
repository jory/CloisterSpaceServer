CloisterSpaceServer::Application.routes.draw do

  match 'tiles' => 'tiles#index'
  match 'edges' => 'edges#index'

  match 'tileInstances/next' => 'tileInstances#next'
  resources :tileInstances

  resources :games do
    match 'roads' => 'roads#index'
    match 'cloisters' => 'cloisters#index'
    match 'cities' => 'cities#index'
    match 'farms' => 'farms#index'
  end
  
end
