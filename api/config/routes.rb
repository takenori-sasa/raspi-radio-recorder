require 'sidekiq/web'
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace 'api' do
    namespace 'v1' do
      resources :records
      resources :programs, only: [:index, :show]
    end
  end
  mount Sidekiq::Web, at: '/sidekiq' if Rails.env.development?
end
