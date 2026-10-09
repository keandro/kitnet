class Usuario < ApplicationRecord
  # Sem :registerable: o sistema não aceita cadastro público. Novos usuários
  # são criados pelo seed ou pelo console; cada um altera os próprios dados
  # em "Minha conta" (ContasController).
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
