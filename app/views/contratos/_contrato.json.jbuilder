json.extract! contrato, :id, :morador_id, :unidade_id, :data_inicio, :data_fim, :valor_aluguel, :status, :created_at, :updated_at
json.url contrato_url(contrato, format: :json)
