Rails.application.routes.draw do
  get 'chats/create'
  get 'chats/show'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check



  # Pour les chats (nested dans trips) :
  # GET /trips/:trip_id/chats - Liste les chats d'un voyage
  # GET /trips/:trip_id/chats/new - Nouveau chat pour ce voyage
  # POST /trips/:trip_id/chats - Créer un chat pour ce voyage

  # ils nous faut des routes chats :
  # /chats post create
  # /chats/:id  get show


  # chats (en dehors du nesting pour show /edit/upate/destroy)
  resources :chats, only: [:show, :create] do
    resources :messages, only: [:create]
  end

  # pages
  get "profile", to: "pages#profile"
  # get "home", to: "pages#home" # on peut ne pas le faire, et landing to connect direct

  # Defines the root path route ("/")
  # root "posts#index"
end
