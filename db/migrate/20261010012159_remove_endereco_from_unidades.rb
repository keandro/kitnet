class RemoveEnderecoFromUnidades < ActiveRecord::Migration[8.1]
  def change
    remove_column :unidades, :endereco, :string
  end
end
