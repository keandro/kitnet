# Locadores (donos) que podem assinar os contratos.
class LocadoresController < ApplicationController
  before_action :set_locador, only: %i[ edit update destroy ]

  # GET /locadores
  def index
    @locadores = Locador.ordenados
    @contratos_por_locador = Contrato.ativo.group(:locador_id).count
  end

  # GET /locadores/new
  def new
    @locador = Locador.new
  end

  # GET /locadores/1/edit
  def edit
  end

  # POST /locadores
  def create
    @locador = Locador.new(locador_params)
    if @locador.save
      redirect_to locadores_path, notice: "Locador #{@locador.nome} adicionado.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH /locadores/1
  def update
    if @locador.update(locador_params)
      redirect_to locadores_path, notice: "Locador atualizado.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /locadores/1
  def destroy
    @locador.destroy!
    redirect_to locadores_path, notice: "Locador #{@locador.nome} removido.", status: :see_other
  end

  private
    def set_locador
      @locador = Locador.find(params.expect(:id))
    end

    def locador_params
      params.expect(locador: [ :nome, :nacionalidade, :estado_civil, :profissao, :cpf, :endereco ])
    end
end
