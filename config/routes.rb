Rails.application.routes.draw do
  resources :trend_trackers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :products do
    collection do
      get "import_jobs/:id", to: "products/import_jobs#show", as: "import_job"
      post "import_jobs", to: "products/import_jobs#create", as: "import_jobs"
    end
  end

  resources :categories
  resources :prices
  resources :price_histories
  resources :order_items
  resources :orders

  resources :carts, shallow: true do
    resources :cart_items
  end
end
