# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@kitnet.local")
admin_password = ENV.fetch("ADMIN_PASSWORD", "senha123456")

# Só cria o admin num banco sem usuários: depois que o e-mail é trocado em
# "Minha conta", rodar o seed de novo não pode recriar o login padrão.
if Usuario.none?
  Usuario.create!(email: admin_email, password: admin_password, password_confirmation: admin_password)
  puts "Usuario admin: #{admin_email} / senha: #{admin_password}"
end

%w[001 002 003 004 101 102 103 104 201 202 203 204].each do |numero|
  Unidade.find_or_create_by!(nome: numero) do |unidade|
    unidade.status = :livre
  end
end

# Não é mais alugada, mas guarda pagamentos do passado.
Unidade.find_or_create_by!(nome: "Antiga casa") do |unidade|
  unidade.status = :descontinuada
end

puts "Unidades cadastradas: #{Unidade.count}"
