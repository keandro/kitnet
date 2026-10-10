# A tarifa com 4 casas faz kWh × tarifa errar alguns centavos em contas
# grandes; com 6 casas o valor total bate com o da conta.
class AumentarPrecisaoDaTarifa < ActiveRecord::Migration[8.1]
  def up
    change_column :contas_energia, :valor_kwh, :decimal, precision: 12, scale: 6
  end

  def down
    change_column :contas_energia, :valor_kwh, :decimal, precision: 10, scale: 4
  end
end
