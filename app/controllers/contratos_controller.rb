class ContratosController < ApplicationController
  before_action :set_contrato, only: %i[ show edit update destroy ]

  # GET /contratos or /contratos.json
  def index
    @contratos = policy_scope(Contrato)
  end

  # GET /contratos/1 or /contratos/1.json
  def show
  end

  # GET /contratos/new
  def new
    @contrato = Contrato.new
    authorize @contrato
  end

  # GET /contratos/1/edit
  def edit
  end

  # POST /contratos or /contratos.json
  def create
    @contrato = Contrato.new(contrato_params)
    authorize @contrato

    respond_to do |format|
      if @contrato.save
        format.html { redirect_to @contrato, notice: "Contrato criado com sucesso." }
        format.json { render :show, status: :created, location: @contrato }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @contrato.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /contratos/1 or /contratos/1.json
  def update
    respond_to do |format|
      if @contrato.update(contrato_params)
        format.html { redirect_to @contrato, notice: "Contrato atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @contrato }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @contrato.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /contratos/1 or /contratos/1.json
  def destroy
    @contrato.destroy!

    respond_to do |format|
      format.html { redirect_to contratos_path, notice: "Contrato removido com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contrato
      @contrato = Contrato.find(params.expect(:id))
      authorize @contrato
    end

    # Only allow a list of trusted parameters through.
    def contrato_params
      params.expect(contrato: [ :morador_id, :unidade_id, :data_inicio, :data_fim, :valor_aluguel, :status, fiador_ids: [] ])
    end
end
