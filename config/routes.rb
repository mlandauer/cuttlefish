Cuttlefish::Application.routes.draw do
  devise_for :admins, :controllers => {
    :sessions => "admins/sessions",
    :registrations => "admins/registrations",
    :passwords => "admins/passwords",
    :invitations => "admins/invitations"
  }
  resources :emails, :only => [:index, :show]
  resources :addresses, :only => [:index, :show]
  resources :test_emails, :only => [:new, :create]
  resources :apps, :only => [:index, :new, :create]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root to: 'main#index'

  get 'status_counts' => 'main#status_counts'
  get 'reputation' => 'main#reputation'
  
  # Open tracking gifs
  get 'o/:hash' => 'deliveries#open_track', :as => :delivery_open_track

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
