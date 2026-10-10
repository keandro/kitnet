Rails.application.routes.draw do
  devise_for :usuarios
  resource :conta, only: %i[edit update], controller: "contas"

  resources :pessoas
  resources :unidades
  resources :contratos
  resources :pagamentos, only: %i[edit update destroy] do
    patch :pagar, on: :member
  end
  get "kitnets", to: "kitnets#index", as: :kitnets

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
