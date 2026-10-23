# Celular do inquilino (só dígitos, com DDD), para enviar mensagens pelo WhatsApp.
class AdicionarCelularAoContrato < ActiveRecord::Migration[8.1]
  def change
    add_column :contratos, :celular, :string
  end
end
