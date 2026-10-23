# Quais kitnets estão ocupadas, pelos contratos ativos.
class OcupacaoController < ApplicationController
  # GET /ocupacao
  def index
    @unidades = Unidade.em_uso.includes(:contratos).order(:nome)
    @ocupadas = @unidades.count(&:contrato_ativo)
  end
end
