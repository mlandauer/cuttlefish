# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  post "/graphql", to: "graphql#execute"

  resource :session,
           only: [],
           as: "admin_session",
           path: "/admins",
           controller: "admins/sessions" do
    get :new, path: "sign_in", as: "new"
    post :create, path: "sign_in"
    match :destroy, path: "sign_out", as: "destroy", via: :delete
  end

  resource :registration,
           only: %i[new create edit update destroy],
           as: "admin_registration",
           path: "/admins",
           controller: "admins/registrations",
           path_names: { new: "sign_up" }

  resource :invitation,
           only: %i[create update],
           as: "admin_invitation",
           path: "/admins/invitation" do
    get :edit, path: "accept", as: :accept
  end

  resource :password,
           only: %i[new create edit update],
           as: "admin_password",
           path: "/admins/password",
           controller: "admins/passwords"

  require "sidekiq/web"
  authenticate :admin, ->(u) { u.site_admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :admins, only: %i[index destroy]
  resources :emails, only: %i[index show], as: :deliveries,
                     controller: "deliveries"
  # Allow "." in the id's by using the constraint
  resources :addresses, only: [], constraints: { id: %r{[^/]+} } do
    member do
      get :from
      get :to
    end
  end
  resources :test_emails, only: %i[new create]
  resources :apps do
    resources :emails, only: :index, as: :deliveries, controller: "deliveries"
    resources :clients, only: :index, as: :clients, controller: "clients"
    resources :deny_lists, only: %i[index destroy], as: :deny_lists, controller: "deny_lists"

    member do
      get "dkim"
      get "webhook"
      post "toggle_dkim"
      post "upgrade_dkim"
    end
  end

  resources :deny_lists, only: %i[index destroy]
  resources :teams, only: :index do
    collection do
      post "invite"
    end
  end

  resources :clients, only: :index

  root to: "landing#index"

  get "dash" => "main#index"
  get "status_counts" => "main#status_counts"
  get "reputation" => "main#reputation"

  # Open tracking gifs
  get "o2/:delivery_id/:hash" => "tracking#open", as: "tracking_open"

  # Link tracking
  get "l2/:delivery_link_id/:hash" => "tracking#click", as: "tracking_click"

  get "/documentation" => "documentation#index"
end
