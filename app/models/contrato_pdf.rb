# Contrato de locação pronto para assinar (PDF), a partir do texto do
# ModeloDeContrato. Os dados vêm do contrato e da ConfiguracaoContrato; o que
# faltar sai como "________" para completar à mão.
class ContratoPdf
  include ActionView::Helpers::NumberHelper
  include UnidadesHelper

  VAZIO = "____________________".freeze

  def initialize(contrato, configuracao = ConfiguracaoContrato.atual)
    @c = contrato
    @cfg = configuracao
  end

  def nome_do_arquivo
    "contrato-kitnet-#{@c.unidade.nome}-#{@c.inquilino.parameterize}.pdf"
  end

  def render
    Prawn::Fonts::AFM.hide_m17n_warning = true
    pdf = Prawn::Document.new(page_size: "A4", margin: [ 60, 64, 70, 64 ], info: { Title: "Contrato de locação — kitnet #{@c.unidade&.nome}" })
    pdf.font "Times-Roman", size: 12
    pdf.default_leading 2

    modelo = ModeloDeContrato.new(@cfg.texto_do_contrato)
    modelo.blocos("fiador" => com_fiador?, "taxa de limpeza" => @cfg.taxa_limpeza.to_d.positive?).each do |tipo, texto|
      texto = preencher(texto)
      case tipo
      when :titulo_principal
        pdf.text texto, inline_format: true, style: :bold, size: 13, align: :center
        pdf.move_down 22
      when :titulo
        pdf.move_down 6
        pdf.text texto, inline_format: true, style: :bold
        pdf.move_down 6
      when :recuado then paragrafo pdf, texto, indent: 36
      when :item then paragrafo pdf, texto, indent: 18, depois: 3
      else paragrafo pdf, texto
      end
    end

    assinaturas pdf
    pdf.render
  end

  private

  # O texto do modelo e os dados vão escapados; só **negrito** e __sublinhado__
  # viram formatação. Um trecho entre colchetes ("[, RG {locatario_rg}]") some
  # quando algum campo dele está vazio.
  def preencher(texto)
    escapar(texto)
      .gsub(ModeloDeContrato::OPCIONAL) do
        trecho = Regexp.last_match(1)
        trecho.scan(ModeloDeContrato::CAMPO).flatten.any? { |campo| valores[campo] == VAZIO } ? "" : trecho
      end
      .gsub(/\*\*(.+?)\*\*/, '<b>\\1</b>')
      .gsub(/__(?=[^_\s])(.+?)(?<=[^_\s])__/, '<u>\\1</u>')
      .gsub(ModeloDeContrato::CAMPO) { valores.fetch($1, $&) }
  end

  def v(valor) = valor.present? ? escapar(valor.to_s) : VAZIO

  # O formato do Prawn só entende &amp; &lt; &gt; (o html_escape também troca
  # aspas e apóstrofos: "D'azul" saía como "D&#39;azul"). A fonte do PDF só tem
  # os caracteres do Windows-1252; os outros (✓, emojis) viram "?" em vez de
  # impedir o PDF de ser gerado.
  def escapar(texto)
    texto.encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?").encode("UTF-8")
         .gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
  end

  def paragrafo(pdf, texto, indent: 0, depois: 8)
    pdf.text texto, inline_format: true, align: :justify, indent_paragraphs: indent
    pdf.move_down depois
  end

  def andar
    andar_label(@c.unidade.nome.to_s[0]).sub("Térreo", "térreo") if @c.unidade
  end

  def dinheiro(valor) = number_to_currency(valor, unit: "R$", separator: ",", delimiter: ".", format: "%u%n")

  def com_fiador? = !@c.sem_fiador_no_contrato?

  # Valores dos {campos}, já escapados.
  def valores
    @valores ||= {
      "locador" => @cfg.locador_nome, "locador_qualificacao" => @cfg.locador_qualificacao,
      "locador_cpf" => @cfg.locador_cpf, "locador_endereco" => @cfg.locador_endereco,
      "locatario" => @c.inquilino, "locatario_nacionalidade" => @c.inquilino_nacionalidade,
      "locatario_estado_civil" => @c.inquilino_estado_civil, "locatario_profissao" => @c.inquilino_profissao,
      "locatario_cpf" => @c.inquilino_cpf, "locatario_rg" => @c.inquilino_rg,
      "fiador" => @c.fiador, "fiador_nacionalidade" => @c.fiador_nacionalidade,
      "fiador_estado_civil" => @c.fiador_estado_civil, "fiador_profissao" => @c.fiador_profissao,
      "fiador_cpf" => @c.fiador_cpf, "fiador_identidade" => @c.fiador_rg, "fiador_endereco" => @c.fiador_endereco,
      "imovel_endereco" => @cfg.imovel_endereco, "andar" => andar, "kitnet" => @c.unidade&.nome, "bairro_cidade" => @cfg.imovel_bairro_cidade,
      "valor" => @c.valor && dinheiro(@c.valor), "valor_extenso" => @c.valor && Extenso.reais(@c.valor),
      "dia_vencimento" => @c.dia_vencimento, "dia_vencimento_extenso" => @c.dia_vencimento && Extenso.numero(@c.dia_vencimento),
      "forma_pagamento" => @c.conta_pagamento&.forma_de_pagamento, "conta_titular" => @c.conta_pagamento&.titular,
      "conta_banco" => @c.conta_pagamento&.banco, "conta_agencia" => @c.conta_pagamento&.agencia,
      "conta_numero" => @c.conta_pagamento&.conta, "conta_pix" => @c.conta_pagamento&.chave_pix,
      "duracao" => @c.duracao_meses, "duracao_extenso" => @c.duracao_meses && Extenso.numero(@c.duracao_meses),
      "inicio" => @c.data_inicio && I18n.l(@c.data_inicio), "termino" => @c.data_fim && I18n.l(@c.data_fim),
      "taxa_limpeza" => @cfg.taxa_limpeza && dinheiro(@cfg.taxa_limpeza),
      "taxa_limpeza_extenso" => @cfg.taxa_limpeza && Extenso.reais(@cfg.taxa_limpeza),
      "foro" => @cfg.foro, "cidade" => @cfg.cidade_assinatura
    }.transform_values { |valor| v(valor) }.tap do |valores|
      # O locatário mora na própria kitnet alugada.
      valores["locatario_endereco"] = valores.values_at("imovel_endereco", "andar").join(", ") +
                                      ", kitnet #{valores["kitnet"]}, #{valores["bairro_cidade"]}"
    end
  end

  def assinaturas(pdf)
    data = I18n.l(Date.current, format: "%d de %B de %Y")
    pessoas = [ [ "LOCADOR", @cfg.locador_nome ], [ "LOCATÁRIO", @c.inquilino ] ]
    pessoas << [ "FIADOR", @c.fiador ] if com_fiador?

    pdf.start_new_page if pdf.cursor < 120 + pessoas.size * 62
    pdf.move_down 18
    pdf.text "#{v(@cfg.cidade_assinatura)}, #{data}.", inline_format: true, align: :center
    pdf.move_down 30

    pessoas.each do |rotulo, nome|
      pdf.move_down 26
      pdf.stroke_horizontal_line 0, 300
      pdf.move_down 4
      pdf.text "<b>#{rotulo}:</b> #{v(nome)}", inline_format: true
    end

    pdf.move_down 26
    pdf.text "<b>Testemunhas:</b>", inline_format: true
    [ 1, 2 ].each do |n|
      pdf.move_down 24
      pdf.text "#{n}. ________________________________________   CPF: ____________________"
    end
  end
end
