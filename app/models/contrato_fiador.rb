class ContratoFiador < ApplicationRecord
  belongs_to :contrato
  belongs_to :pessoa
end
