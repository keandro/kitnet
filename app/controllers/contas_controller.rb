class ContasController < ApplicationController
  include Devise::Controllers::Rememberable

  def edit
    @usuario = current_usuario
  end

  def update
    @usuario = current_usuario

    if @usuario.update_with_password(conta_params)
      # Trocar a senha invalida a sessão e o "lembrar de mim" atuais; mantém
      # este aparelho conectado (os outros precisarão entrar de novo).
      bypass_sign_in(@usuario)
      remember_me(@usuario)
      redirect_to edit_conta_path, notice: "Conta atualizada com sucesso."
    else
      @usuario.clean_up_passwords
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def conta_params
    params.expect(usuario: [ :email, :password, :password_confirmation, :current_password ])
  end
end
