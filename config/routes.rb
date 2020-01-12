Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root "players#new"
  resources :players, only: [:new, :create, :index, :destroy] do
    get 'regroup', on: :collection
    patch 'promote', on: :member
  end
end
