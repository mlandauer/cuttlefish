Cuttlefish::Application.routes.draw do
  devise_for :admins, controllers: {
    sessions: "admins/sessions",
    registrations: "admins/registrations",
    passwords: "admins/passwords",
    invitations: "admins/invitations"
  }
  resources :emails, only: [:index, :show], as: :deliveries, controller: "deliveries"
  resources :addresses, only: [] do
    member do
      get :from
      get :to
    end
  end
  resources :test_emails, only: [:new, :create]
  resources :apps do
    resources :emails, only: :index, as: :deliveries, controller: "deliveries"
    member do
      post 'new_password'
      post 'lock_password'
      get 'dkim'
      post 'toggle_dkim'
    end
  end

  resources :links, only: [:index, :show]
  resources :black_lists, only: [:index, :destroy]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root to: 'landing#index'

  get 'dash' => 'main#index'
  get 'status_counts' => 'main#status_counts'
  get 'reputation' => 'main#reputation'

  # Open tracking gifs
  get 'o/:delivery_id/:hash' => 'tracking#open', as: "tracking_open"

  # Link tracking
  get 'l/:delivery_link_id/:hash' => 'tracking#click', as: "tracking_click"

  get '/documentation' => 'documentation#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
