# Cópias do banco SQLite: exportar, importar (restaurar) e o backup automático
# diário. As cópias ficam em storage/backups, que não vai para o git.
module BancoBackup
  PASTA = Rails.root.join("storage/backups")
  MANTER_AUTOMATICOS = 15
  CABECALHO_SQLITE = "SQLite format 3\x00".b
  TABELAS_OBRIGATORIAS = %w[schema_migrations unidades pagamentos].freeze
  TAMANHO_MAXIMO = 50.megabytes

  class ArquivoInvalido < StandardError; end

  Copia = Data.define(:nome, :caminho, :data, :tamanho)

  module_function

  # Grava uma cópia consistente do banco em uso (pode ser feita com o app rodando).
  def copiar_para(destino)
    FileUtils.mkdir_p(File.dirname(destino))
    FileUtils.rm_f(destino)
    origem = conexao_sqlite
    SQLite3::Database.new(destino.to_s) do |copia|
      backup = SQLite3::Backup.new(copia, "main", origem, "main")
      backup.step(-1)
      backup.finish
    end
    destino
  end

  def criar(prefixo)
    copiar_para(PASTA.join("#{prefixo}-#{Time.current.strftime('%Y-%m-%d_%H-%M-%S')}.sqlite3"))
  end

  # Um backup por dia (auto-AAAA-MM-DD), mantendo os últimos MANTER_AUTOMATICOS.
  def automatico_do_dia
    destino = PASTA.join("auto-#{Date.current.iso8601}.sqlite3")
    return if destino.exist?

    copiar_para(destino)
    automaticos = PASTA.glob("auto-*.sqlite3").sort
    automaticos.first([ automaticos.size - MANTER_AUTOMATICOS, 0 ].max).each(&:delete)
  rescue StandardError => e
    Rails.logger.error("Backup automático falhou: #{e.class}: #{e.message}")
  end

  def copias
    PASTA.glob("*.sqlite3").map { |p| Copia.new(nome: p.basename.to_s, caminho: p, data: p.mtime, tamanho: p.size) }
         .sort_by(&:data).reverse
  end

  # Só devolve arquivos que estão na lista de cópias: o nome vindo do link
  # nunca vira caminho diretamente.
  def encontrar(nome)
    copias.find { |copia| copia.nome == nome.to_s }
  end

  def resumo
    {
      "kitnets" => Unidade.count,
      "pagamentos" => Pagamento.count,
      "contratos" => Contrato.count,
      "contas de energia" => ContaEnergia.count,
      "leituras" => LeituraEnergia.count,
      "meses de energia solar" => EnergiaSolarMensal.count,
      "meses com custos" => FechamentoMensal.count
    }
  end

  def tamanho_do_banco
    caminho = Rails.root.join(ActiveRecord::Base.connection_db_config.database)
    File.size(caminho) + File.size?("#{caminho}-wal").to_i
  end

  # Substitui todos os dados pelos do arquivo enviado. Antes, guarda uma cópia
  # do banco atual; depois, aplica as migrações que o backup ainda não tinha.
  def restaurar!(arquivo)
    # Trabalha numa cópia temporária: abrir um banco em modo WAL cria arquivos
    # -wal/-shm ao lado dele, e o original (upload ou cópia da pasta) fica intacto.
    temporario = Rails.root.join("tmp/backup-importado-#{SecureRandom.hex(4)}.sqlite3")
    FileUtils.cp(arquivo.respond_to?(:path) ? arquivo.path : arquivo.to_s, temporario)
    validar!(temporario.to_s)
    copia_anterior = criar("antes-importacao")

    destino = conexao_sqlite
    SQLite3::Database.new(temporario.to_s) do |origem|
      backup = SQLite3::Backup.new(destino, "main", origem, "main")
      backup.step(-1)
      backup.finish
    end

    ActiveRecord::Base.connection_pool.migration_context.migrate
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    copia_anterior
  ensure
    FileUtils.rm_f([ temporario, "#{temporario}-wal", "#{temporario}-shm" ].compact.map(&:to_s)) if temporario
  end

  def validar!(caminho)
    raise ArquivoInvalido, "Arquivo maior que #{TAMANHO_MAXIMO / 1.megabyte} MB." if File.size(caminho) > TAMANHO_MAXIMO
    raise ArquivoInvalido, "O arquivo não é um banco SQLite." unless File.binread(caminho, CABECALHO_SQLITE.bytesize) == CABECALHO_SQLITE

    SQLite3::Database.new(caminho) do |db|
      tabelas = db.execute("SELECT name FROM sqlite_master WHERE type = 'table'").flatten
      faltando = TABELAS_OBRIGATORIAS - tabelas
      raise ArquivoInvalido, "O arquivo não é um backup do LF Kitnets (faltam as tabelas #{faltando.join(', ')})." if faltando.any?

      versoes = db.execute("SELECT version FROM schema_migrations").flatten.map(&:to_i)
      conhecidas = ActiveRecord::Base.connection_pool.migration_context.migrations.map(&:version)
      raise ArquivoInvalido, "O backup é de uma versão mais nova do app; atualize o app antes de importar." if (versoes - conhecidas).any?
    end
  rescue SQLite3::Exception => e
    raise ArquivoInvalido, "Não consegui ler o arquivo: #{e.message}"
  end

  def conexao_sqlite
    ActiveRecord::Base.connection.raw_connection
  end
end
