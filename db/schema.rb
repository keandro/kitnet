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

ActiveRecord::Schema[8.1].define(version: 2026_07_15_224510) do
  create_table "contrato_fiadores", force: :cascade do |t|
    t.integer "contrato_id", null: false
    t.datetime "created_at", null: false
    t.integer "pessoa_id", null: false
    t.datetime "updated_at", null: false
    t.index ["contrato_id"], name: "index_contrato_fiadores_on_contrato_id"
    t.index ["pessoa_id"], name: "index_contrato_fiadores_on_pessoa_id"
  end

  create_table "contratos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data_fim"
    t.date "data_inicio"
    t.integer "dia_pagamento"
    t.integer "morador_id", null: false
    t.integer "status"
    t.integer "unidade_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_aluguel"
    t.index ["morador_id"], name: "index_contratos_on_morador_id"
    t.index ["unidade_id"], name: "index_contratos_on_unidade_id"
  end

  create_table "pagamentos", force: :cascade do |t|
    t.integer "contrato_id", null: false
    t.datetime "created_at", null: false
    t.date "data_pagamento"
    t.date "data_vencimento"
    t.text "observacoes"
    t.datetime "updated_at", null: false
    t.decimal "valor"
    t.index ["contrato_id"], name: "index_pagamentos_on_contrato_id"
  end

  create_table "pessoas", force: :cascade do |t|
    t.string "cpf"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "endereco"
    t.string "nome"
    t.string "telefone"
    t.datetime "updated_at", null: false
  end

  create_table "unidades", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "endereco"
    t.string "nome"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.decimal "valor_base"
  end

  create_table "usuarios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "contrato_fiadores", "contratos"
  add_foreign_key "contrato_fiadores", "pessoas"
  add_foreign_key "contratos", "pessoas", column: "morador_id"
  add_foreign_key "contratos", "unidades"
  add_foreign_key "pagamentos", "contratos"
end
