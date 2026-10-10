# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

%w[001 002 003 004 101 102 103 104 201 202 203 204].each do |numero|
  Unidade.find_or_create_by!(nome: numero)
end

# Não é mais alugada, mas guarda pagamentos do passado.
Unidade.find_or_create_by!(nome: "Antiga casa") do |unidade|
  unidade.descontinuada = true
end

puts "Unidades cadastradas: #{Unidade.count}"
