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

ActiveRecord::Schema[8.1].define(version: 2026_10_10_030336) do
  create_table "contas_energia", force: :cascade do |t|
    t.integer "ano", null: false
    t.integer "mes", null: false
    t.decimal "kwh_total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_kwh", precision: 12, scale: 6
    t.index ["ano", "mes"], name: "index_contas_energia_on_ano_and_mes", unique: true
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
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "leituras_energia", "contas_energia", column: "conta_energia_id"
  add_foreign_key "leituras_energia", "unidades"
  add_foreign_key "pagamentos", "unidades"
end
