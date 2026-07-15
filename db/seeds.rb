# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@kitnet.local")
admin_password = ENV.fetch("ADMIN_PASSWORD", "senha123456")

Usuario.find_or_create_by!(email: admin_email) do |usuario|
  usuario.password = admin_password
  usuario.password_confirmation = admin_password
end

puts "Usuario admin: #{admin_email} / senha: #{admin_password}"
