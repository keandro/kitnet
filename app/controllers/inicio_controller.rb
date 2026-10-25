# Página inicial: avisos de hoje e o resumo do ano atual.
class InicioController < ApplicationController
  # GET /
  def index
    hoje = Date.current
    @notificacoes = Notificacoes.new(hoje)
    @resumo = ResumoFinanceiro.new(hoje.year)
  end
end
