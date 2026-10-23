class BackupsController < ApplicationController
  # GET /backup
  def index
    @resumo = BancoBackup.resumo
    @tamanho = BancoBackup.tamanho_do_banco
    @copias = BancoBackup.copias
  end

  # GET /backup/exportar
  def exportar
    arquivo = Rails.root.join("tmp/backup-exportado-#{SecureRandom.hex(4)}.sqlite3")
    BancoBackup.copiar_para(arquivo)
    send_data File.binread(arquivo), filename: "lf-kitnets-#{Time.current.strftime('%Y-%m-%d_%H-%M')}.sqlite3",
                                     type: "application/vnd.sqlite3", disposition: "attachment"
  ensure
    FileUtils.rm_f(arquivo) if arquivo
  end

  # POST /backup/importar
  def importar
    arquivo = params[:arquivo]
    return redirect_to(backups_path, alert: "Escolha um arquivo de backup para importar.") unless arquivo.respond_to?(:path)

    anterior = BancoBackup.restaurar!(arquivo)
    redirect_to backups_path, notice: "Backup importado. Os dados de antes ficaram guardados em #{anterior.basename}."
  rescue BancoBackup::ArquivoInvalido => e
    redirect_to backups_path, alert: e.message
  end

  # GET /backup/copias/:nome
  def baixar
    copia = BancoBackup.encontrar(params[:nome])
    return head(:not_found) unless copia

    send_file copia.caminho, filename: copia.nome, type: "application/vnd.sqlite3", disposition: "attachment"
  end
end
