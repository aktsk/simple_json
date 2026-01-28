# frozen_string_literal: true

Rails.application.routes.draw do
  resources :posts, only: :show do
    collection do
      get :hello
    end
  end
  namespace :simple_json_migration do
    resources :posts, only: :show
    resources :posts_with_wrong_template, only: :show
    resources :posts_without_partial, only: :show
    resources :posts_without_template, only: :show
  end
  resources :posts_with_cache, only: :show
  resources :posts_with_multiple_view_paths, only: :show

  resources :benchmarks, only: [] do
    collection do
      get :jb, defaults: { format: :json }
      get :jbuilder, defaults: { format: :json }
      get :simple_json_oj, defaults: { format: :json }
      get :simple_json_as_json, defaults: { format: :json }
    end
  end

  if Rails::VERSION::MAJOR >= 5
    namespace :api do
      resources :posts, only: :show
      get '/renamed_posts/:id', to: 'posts#renamed_show'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
