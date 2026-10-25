# Água e esgoto em dois relógios; agua_esgoto continua sendo o total do mês.
# Nos meses já lançados, o valor que existia vira o do relógio 1.
class DoisRelogiosDeAgua < ActiveRecord::Migration[8.1]
  def up
    add_column :fechamentos_mensais, :agua_esgoto_1, :decimal, precision: 10, scale: 2
    add_column :fechamentos_mensais, :agua_esgoto_2, :decimal, precision: 10, scale: 2
    execute "UPDATE fechamentos_mensais SET agua_esgoto_1 = agua_esgoto"
  end

  def down
    remove_column :fechamentos_mensais, :agua_esgoto_1
    remove_column :fechamentos_mensais, :agua_esgoto_2
  end
end
