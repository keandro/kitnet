# A conta de energia passa a guardar a tarifa (valor do kWh) digitada, e o
# valor total vira kWh × tarifa. O valor realmente pago (já com o desconto da
# energia solar) fica na página Energia Solar.
class TarifaNaContaEnergia < ActiveRecord::Migration[8.1]
  class Conta < ActiveRecord::Base
    self.table_name = "contas_energia"
  end

  def up
    add_column :contas_energia, :valor_kwh, :decimal, precision: 10, scale: 4

    Conta.reset_column_information
    Conta.where.not(valor_total: nil).where.not(kwh_total: [ nil, 0 ]).find_each do |conta|
      conta.update_columns(valor_kwh: (conta.valor_total / conta.kwh_total).round(4))
    end

    remove_column :contas_energia, :valor_total
    remove_column :fechamentos_mensais, :energia_solar
  end

  def down
    add_column :fechamentos_mensais, :energia_solar, :decimal, precision: 10, scale: 2
    add_column :contas_energia, :valor_total, :decimal, precision: 10, scale: 2

    Conta.reset_column_information
    Conta.where.not(valor_kwh: nil).find_each do |conta|
      conta.update_columns(valor_total: (conta.kwh_total.to_d * conta.valor_kwh).round(2))
    end

    remove_column :contas_energia, :valor_kwh
  end
end
