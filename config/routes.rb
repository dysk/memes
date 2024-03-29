EspagoMemes::Application.routes.draw do
  authenticated :user do
    root :to => 'memes#index'
  end
  root :to => "memes#index"
  devise_for :users
  resources :users
  resources :memes, only: [:create, :destroy, :index, :new, :show] do
    member do
      post   '/like' => 'likes#create'
      delete '/like' => 'likes#destroy', :as => :unlike
    end
  end
  resources :images, only: [:create, :destroy, :index, :new, :show] do
    member do
      resources :memes, only: [:new, :create], as: :image_meme
    end
  end
end