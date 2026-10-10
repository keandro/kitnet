class AddDuracaoMesesToContratos < ActiveRecord::Migration[8.1]
  # Modelo isolado: a migração não deve depender das validações e callbacks
  # atuais de Contrato.
  class ContratoSemCallbacks < ActiveRecord::Base
    self.table_name = "contratos"
  end

  def up
    add_column :contratos, :duracao_meses, :integer

    # Deduz a duração dos contratos existentes a partir das datas de início e fim.
    ContratoSemCallbacks.where.not(data_inicio: nil).where.not(data_fim: nil).find_each do |c|
      meses = (c.data_fim.year * 12 + c.data_fim.month) - (c.data_inicio.year * 12 + c.data_inicio.month)
      c.update_columns(duracao_meses: [ meses, 1 ].max)
    end
  end

  def down
    remove_column :contratos, :duracao_meses
  end
end
