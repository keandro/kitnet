json.extract! pessoa, :id, :nome, :cpf, :telefone, :email, :endereco, :created_at, :updated_at
json.url pessoa_url(pessoa, format: :json)
