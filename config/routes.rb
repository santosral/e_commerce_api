require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Web application that can display the current state of a Sidekiq.
  mount Sidekiq::Web => "/sidekiq"

  # Defines the root path route ("/")
  # root "posts#index"
  resources :products do
    collection do
      get "import_jobs/:id", to: "products/import_jobs#show", as: "import_job"
      post "import_jobs", to: "products/import_jobs#create", as: "import_jobs"
    end

    resources :trends, only: :index
    resources :prices, only: :index
  end

  resources :categories

  resources :carts do
    resources :cart_items
  end

  resources :orders do
    resources :order_items
  end

  namespace :prices do
    resources :adjustment_rules
  end
end
