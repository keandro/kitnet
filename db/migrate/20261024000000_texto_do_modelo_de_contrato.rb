class TextoDoModeloDeContrato < ActiveRecord::Migration[8.1]
  def change
    add_column :configuracoes_contrato, :texto_modelo, :text
  end
end
