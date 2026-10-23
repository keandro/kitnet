# A conta passa a ser lançada pelo valor total (o que vem na conta, sem o
# desconto da energia solar); o valor do kWh é calculado: valor total ÷ kWh.
class GuardarValorTotalDaConta < ActiveRecord::Migration[8.1]
  class Conta < ActiveRecord::Base
    self.table_name = "contas_energia"
  end

  def up
    add_column :contas_energia, :valor_total, :decimal, precision: 10, scale: 2
    Conta.reset_column_information
    Conta.where.not(kwh_total: nil).where.not(valor_kwh: nil).find_each do |conta|
      conta.update_columns(valor_total: (conta.kwh_total * conta.valor_kwh).round(2))
    end
  end

  def down
    remove_column :contas_energia, :valor_total
  end
end
