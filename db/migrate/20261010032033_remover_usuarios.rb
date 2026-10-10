# Sem dados pessoais, o app deixou de ter login: a tabela de usuários sai.
class RemoverUsuarios < ActiveRecord::Migration[8.1]
  def up
    drop_table :usuarios
  end

  def down
    create_table :usuarios do |t|
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.timestamps
    end
    add_index :usuarios, :email, unique: true
    add_index :usuarios, :reset_password_token, unique: true
  end
end
