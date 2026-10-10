class UnidadesController < ApplicationController
  before_action :set_unidade, only: %i[ show edit update destroy ]

  # GET /unidades or /unidades.json
  def index
    @unidades = policy_scope(Unidade)
  end

  # GET /unidades/1 or /unidades/1.json
  def show
  end

  # GET /unidades/new
  def new
    @unidade = Unidade.new
    authorize @unidade
  end

  # GET /unidades/1/edit
  def edit
  end

  # POST /unidades or /unidades.json
  def create
    @unidade = Unidade.new(unidade_params)
    authorize @unidade

    respond_to do |format|
      if @unidade.save
        format.html { redirect_to @unidade, notice: "Unidade criada com sucesso." }
        format.json { render :show, status: :created, location: @unidade }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @unidade.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /unidades/1 or /unidades/1.json
  def update
    respond_to do |format|
      if @unidade.update(unidade_params)
        format.html { redirect_to @unidade, notice: "Unidade atualizada com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @unidade }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @unidade.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /unidades/1 or /unidades/1.json
  def destroy
    @unidade.destroy!

    respond_to do |format|
      format.html { redirect_to unidades_path, notice: "Unidade removida com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unidade
      @unidade = Unidade.find(params.expect(:id))
      authorize @unidade
    end

    # Only allow a list of trusted parameters through.
    def unidade_params
      params.expect(unidade: [ :nome, :valor_base, :status ])
    end
end
