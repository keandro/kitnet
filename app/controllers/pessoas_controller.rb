class PessoasController < ApplicationController
  before_action :set_pessoa, only: %i[ show edit update destroy ]

  # GET /pessoas or /pessoas.json
  def index
    @pessoas = policy_scope(Pessoa)
  end

  # GET /pessoas/1 or /pessoas/1.json
  def show
  end

  # GET /pessoas/new
  def new
    @pessoa = Pessoa.new
    authorize @pessoa
  end

  # GET /pessoas/1/edit
  def edit
  end

  # POST /pessoas or /pessoas.json
  def create
    @pessoa = Pessoa.new(pessoa_params)
    authorize @pessoa

    respond_to do |format|
      if @pessoa.save
        format.html { redirect_to @pessoa, notice: "Pessoa criada com sucesso." }
        format.json { render :show, status: :created, location: @pessoa }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @pessoa.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /pessoas/1 or /pessoas/1.json
  def update
    respond_to do |format|
      if @pessoa.update(pessoa_params)
        format.html { redirect_to @pessoa, notice: "Pessoa atualizada com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @pessoa }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @pessoa.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /pessoas/1 or /pessoas/1.json
  def destroy
    @pessoa.destroy!

    respond_to do |format|
      format.html { redirect_to pessoas_path, notice: "Pessoa removida com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pessoa
      @pessoa = Pessoa.find(params.expect(:id))
      authorize @pessoa
    end

    # Only allow a list of trusted parameters through.
    def pessoa_params
      params.expect(pessoa: [ :nome, :cpf, :telefone, :email, :endereco ])
    end
end
