Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "players#new"
  resources :players, only: [:new, :create, :index, :destroy] do
    get 'regroup', on: :collection
    patch 'promote', on: :member
  end
end
