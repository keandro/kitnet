# PDF do contrato, guardado no próprio banco (assim entra no backup).
# Tabela separada para as listas de contratos não carregarem o arquivo.
class CriarDocumentosDeContrato < ActiveRecord::Migration[8.1]
  def change
    create_table :contrato_documentos do |t|
      t.references :contrato, null: false, foreign_key: true, index: { unique: true }
      t.string :nome, null: false
      t.integer :tamanho, null: false
      t.binary :dados, null: false

      t.timestamps
    end
  end
end
