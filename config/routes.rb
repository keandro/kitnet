Rails.application.routes.draw do
  resources :unidades, path: "kitnets", only: %i[index show edit update]
  resources :pagamentos, except: %i[show]
  # antes de resources :contratos, senão "modelo" seria lido como o id de um contrato
  resource :modelo_de_contrato, path: "contratos/modelo", only: %i[edit update], controller: "configuracoes_contrato"
  get "contratos/modelo/exemplo.pdf", to: "configuracoes_contrato#exemplo", as: :exemplo_do_modelo_de_contrato, format: false
  resources :contratos, except: %i[show] do
    patch :finalizar, on: :member
    patch :enviar_pdf, on: :member
  end
  get "contratos/:id/contrato.pdf", to: "contratos#pdf", as: :pdf_contrato, format: false
  get "contratos/:id/para-assinar.pdf", to: "contratos#para_assinar", as: :contrato_para_assinar, format: false
  resources :contas_pagamento, path: "contas-para-pagamento", except: %i[show]
  get "ocupacao", to: "ocupacao#index", as: :ocupacao
  get "mais", to: "mais#index", as: :mais
  get "financas", to: "financas#index", as: :financas
  scope "backup" do
    get "", to: "backups#index", as: :backups
    get "exportar", to: "backups#exportar", as: :exportar_backup
    post "importar", to: "backups#importar", as: :importar_backup
    get "copias/:nome", to: "backups#baixar", as: :baixar_backup, constraints: { nome: /[^\/]+/ }, format: false
  end
  get "energia", to: "energia#index", as: :energia
  get "energia-solar", to: "energia_solar#index", as: :energia_solar
  patch "energia-solar/:ano/:mes", to: "energia_solar#update", as: :apuracao_energia_solar, constraints: { ano: /\d{4}/, mes: /\d{1,2}/ }
  patch "energia/leituras/:id/pagar", to: "energia#pagar", as: :pagar_leitura_energia
  patch "energia/leituras/:id/desfazer-pagamento", to: "energia#desfazer_pagamento", as: :desfazer_pagamento_leitura_energia
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

  # A página inicial é Finanças.
  root to: redirect("/financas")
end
