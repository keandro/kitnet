# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_26_020000) do
  create_table "configuracoes_contrato", force: :cascade do |t|
    t.string "imovel_endereco"
    t.string "imovel_bairro_cidade"
    t.string "cidade_assinatura"
    t.string "foro"
    t.decimal "taxa_limpeza", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "texto_modelo"
  end

  create_table "contas_energia", force: :cascade do |t|
    t.integer "ano", null: false
    t.integer "mes", null: false
    t.decimal "kwh_total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_kwh", precision: 12, scale: 6
    t.decimal "valor_total", precision: 10, scale: 2
    t.index ["ano", "mes"], name: "index_contas_energia_on_ano_and_mes", unique: true
  end

  create_table "contas_pagamento", force: :cascade do |t|
    t.string "titular", null: false
    t.string "banco_codigo"
    t.string "banco_nome"
    t.string "agencia"
    t.string "conta"
    t.string "chave_pix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contrato_documentos", force: :cascade do |t|
    t.integer "contrato_id", null: false
    t.string "nome", null: false
    t.integer "tamanho", null: false
    t.binary "dados", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contrato_id"], name: "index_contrato_documentos_on_contrato_id", unique: true
  end

  create_table "contratos", force: :cascade do |t|
    t.integer "unidade_id", null: false
    t.string "inquilino", null: false
    t.string "fiador"
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.integer "duracao_meses", null: false
    t.integer "dia_vencimento", null: false
    t.date "data_inicio"
    t.integer "status", default: 0, null: false
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "celular"
    t.string "inquilino_cpf"
    t.string "inquilino_rg"
    t.string "fiador_cpf"
    t.string "fiador_rg"
    t.string "fiador_endereco"
    t.string "inquilino_nacionalidade"
    t.string "inquilino_estado_civil"
    t.string "inquilino_profissao"
    t.string "fiador_nacionalidade"
    t.string "fiador_estado_civil"
    t.string "fiador_profissao"
    t.integer "conta_pagamento_id"
    t.date "reajustado_em"
    t.integer "locador_id"
    t.index ["conta_pagamento_id"], name: "index_contratos_on_conta_pagamento_id"
    t.index ["locador_id"], name: "index_contratos_on_locador_id"
    t.index ["unidade_id", "status"], name: "index_contratos_on_unidade_id_and_status"
    t.index ["unidade_id"], name: "index_contratos_on_unidade_id"
  end

  create_table "energia_solar_mensal", force: :cascade do |t|
    t.integer "ano", null: false
    t.integer "mes", null: false
    t.decimal "valor_apartamento", precision: 10, scale: 2
    t.decimal "pago_apartamento", precision: 10, scale: 2
    t.decimal "pago_kitnets", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ano", "mes"], name: "index_energia_solar_mensal_on_ano_and_mes", unique: true
  end

  create_table "fechamentos_mensais", force: :cascade do |t|
    t.integer "ano", null: false
    t.integer "mes", null: false
    t.decimal "despesas_gerais", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "agua_esgoto", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "agua_esgoto_1", precision: 10, scale: 2
    t.decimal "agua_esgoto_2", precision: 10, scale: 2
    t.index ["ano", "mes"], name: "index_fechamentos_mensais_on_ano_and_mes", unique: true
  end

  create_table "leituras_energia", force: :cascade do |t|
    t.integer "conta_energia_id", null: false
    t.integer "unidade_id", null: false
    t.decimal "leitura_anterior", precision: 12, scale: 2
    t.decimal "leitura_atual", precision: 12, scale: 2
    t.date "data_pagamento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conta_energia_id", "unidade_id"], name: "index_leituras_energia_on_conta_energia_id_and_unidade_id", unique: true
    t.index ["conta_energia_id"], name: "index_leituras_energia_on_conta_energia_id"
    t.index ["unidade_id"], name: "index_leituras_energia_on_unidade_id"
  end

  create_table "locadores", force: :cascade do |t|
    t.string "nome", null: false
    t.string "nacionalidade"
    t.string "estado_civil"
    t.string "profissao"
    t.string "cpf"
    t.string "endereco"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pagamentos", force: :cascade do |t|
    t.integer "unidade_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data_pagamento", null: false
    t.text "observacoes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_pagamento"], name: "index_pagamentos_on_data_pagamento"
    t.index ["unidade_id"], name: "index_pagamentos_on_unidade_id"
  end

  create_table "unidades", force: :cascade do |t|
    t.string "nome"
    t.decimal "valor_base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "descontinuada", default: false, null: false
    t.integer "dia_pagamento"
  end

  add_foreign_key "contrato_documentos", "contratos"
  add_foreign_key "contratos", "contas_pagamento"
  add_foreign_key "contratos", "locadores"
  add_foreign_key "contratos", "unidades"
  add_foreign_key "leituras_energia", "contas_energia", column: "conta_energia_id"
  add_foreign_key "leituras_energia", "unidades"
  add_foreign_key "pagamentos", "unidades"
end
