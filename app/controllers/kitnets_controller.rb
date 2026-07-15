class KitnetsController < ApplicationController
  def index
    unidades = policy_scope(Unidade).order(:nome)
    @grupos = unidades.group_by { |unidade| unidade.nome.to_s[0] }.sort.to_h
  end
end
