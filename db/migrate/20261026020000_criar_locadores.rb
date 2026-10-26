# Mais de um locador: cada contrato escolhe o seu. O locador que estava no
# modelo do contrato vira o primeiro, e os contratos existentes ficam com ele.
class CriarLocadores < ActiveRecord::Migration[8.1]
  def up
    create_table :locadores do |t|
      t.string :nome, null: false
      t.string :nacionalidade
      t.string :estado_civil
      t.string :profissao
      t.string :cpf
      t.string :endereco
      t.timestamps
    end
    add_reference :contratos, :locador, foreign_key: true

    nome, qualificacao, cpf, endereco = select_rows("SELECT locador_nome, locador_qualificacao, locador_cpf, locador_endereco FROM configuracoes_contrato LIMIT 1").first
    if nome.present?
      nacionalidade, estado_civil, profissao = qualificacao.to_s.split(",", 3).map { |parte| parte.strip.presence }
      agora = quote(Time.current)
      id = insert(<<~SQL)
        INSERT INTO locadores (nome, nacionalidade, estado_civil, profissao, cpf, endereco, created_at, updated_at)
        VALUES (#{[ nome, nacionalidade, estado_civil, profissao, cpf, endereco ].map { |v| quote(v) }.join(", ")}, #{agora}, #{agora})
      SQL
      update("UPDATE contratos SET locador_id = #{id.to_i}")
    end

    remove_column :configuracoes_contrato, :locador_nome
    remove_column :configuracoes_contrato, :locador_qualificacao
    remove_column :configuracoes_contrato, :locador_cpf
    remove_column :configuracoes_contrato, :locador_endereco
  end

  def down
    add_column :configuracoes_contrato, :locador_nome, :string
    add_column :configuracoes_contrato, :locador_qualificacao, :string
    add_column :configuracoes_contrato, :locador_cpf, :string
    add_column :configuracoes_contrato, :locador_endereco, :string
    remove_reference :contratos, :locador, foreign_key: true
    drop_table :locadores
  end
end
