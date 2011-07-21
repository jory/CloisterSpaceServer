CloisterSpaceServer::Application.routes.draw do

  match 'tiles' => 'tiles#index'
  match 'edges' => 'edges#index'

  resources :games do
    match 'roads' => 'roads#index'
    match 'cloisters' => 'cloisters#index'
    match 'cities' => 'cities#index'
    match 'farms' => 'farms#index'

    match 'tileInstances/next' => 'tileInstances#next'
    match 'tileInstances/place/:id' => 'tileInstances#update'
    match 'tileInstances/:status' => 'tileInstances#index'
  end

  root :to => 'games#index'
end
