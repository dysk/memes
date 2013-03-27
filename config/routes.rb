EspagoMemes::Application.routes.draw do
  authenticated :user do
    root :to => 'memes#index'
  end
  root :to => "memes#index"
  devise_for :users
  resources :users
  resources :memes, only: [:create, :index, :new, :show]
  resources :images
end