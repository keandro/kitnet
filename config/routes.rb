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
  get "financas", to: "financas#index", as: :financas
  get "energia", to: "energia#index", as: :energia
  get "energia-solar", to: "energia_solar#index", as: :energia_solar
  patch "energia-solar/:ano/:mes", to: "energia_solar#update", as: :apuracao_energia_solar, constraints: { ano: /\d{4}/, mes: /\d{1,2}/ }
  patch "energia/leituras/:id/pagar", to: "energia#pagar", as: :pagar_leitura_energia
  scope "energia/:ano/:mes", constraints: { ano: /\d{4}/, mes: /\d{1,2}/ } do
    patch "", to: "energia#update", as: :conta_energia
    get "leituras", to: "energia#edit_leituras", as: :editar_leituras_energia
    patch "leituras", to: "energia#update_leituras", as: :leituras_energia
  end
  scope "financas/:ano/:mes", constraints: { ano: /\d{4}/, mes: /\d{1,2}/ } do
    get "editar", to: "fechamentos_mensais#edit", as: :editar_fechamento_mensal
    patch "", to: "fechamentos_mensais#update", as: :fechamento_mensal
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
