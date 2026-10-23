# Contrato de locação pronto para assinar (PDF), a partir do modelo usado nas
# kitnets. Os dados vêm do contrato e da ConfiguracaoContrato; o que faltar
# sai como "________" para completar à mão.
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
    pdf = Prawn::Document.new(page_size: "A4", margin: [ 60, 64, 70, 64 ], info: { Title: "Contrato de locação — kitnet #{@c.unidade.nome}" })
    pdf.font "Times-Roman", size: 12
    pdf.default_leading 2

    pdf.text "CONTRATO DE LOCAÇÃO RESIDENCIAL POR PRAZO DETERMINADO", style: :bold, size: 13, align: :center
    pdf.move_down 22
    paragrafo pdf, "Contrato de locação de um imóvel situado na #{v(@cfg.imovel_endereco)}, #{andar}, kitnet #{@c.unidade.nome}, " \
                   "#{v(@cfg.imovel_bairro_cidade)}, no qual se destina para locação exclusivamente residencial, vedada utilização para qualquer outro fim.",
              indent: 36
    pdf.move_down 10

    partes.each { |rotulo, texto| paragrafo pdf, "<b>#{rotulo} –</b> #{texto}" }

    pdf.move_down 6
    numero = 0
    clausulas.each do |tipo, texto|
      if tipo == :titulo
        pdf.move_down 6
        pdf.text texto, style: :bold
        pdf.move_down 6
      elsif tipo == :item
        paragrafo pdf, texto, indent: 18, depois: 3
      else
        numero += 1
        paragrafo pdf, "#{numero}- #{texto}"
      end
    end

    assinaturas pdf
    rodape pdf
    pdf.render
  end

  private

  # Texto do usuário vai escapado; só as marcas <b> do modelo são formatação.
  def v(valor) = valor.present? ? ERB::Util.html_escape(valor.to_s) : VAZIO

  def paragrafo(pdf, texto, indent: 0, depois: 8)
    pdf.text texto, inline_format: true, align: :justify, indent_paragraphs: indent
    pdf.move_down depois
  end

  def andar
    andar_label(@c.unidade.nome.to_s[0]).sub("Térreo", "térreo")
  end

  def dinheiro(valor) = number_to_currency(valor, unit: "R$", separator: ",", delimiter: ".", format: "%u%n")

  def qualificacao(nacionalidade, estado_civil, profissao)
    [ nacionalidade, estado_civil, profissao ].map { |x| v(x) }.join(", ")
  end

  # O locatário mora na própria kitnet alugada.
  def endereco_da_kitnet
    "#{v(@cfg.imovel_endereco)}, #{andar}, kitnet #{@c.unidade.nome}, #{v(@cfg.imovel_bairro_cidade)}"
  end

  def partes
    lista = [
      [ "LOCADOR", "<b>#{v(@cfg.locador_nome)}</b>, #{v(@cfg.locador_qualificacao)}, CPF #{v(@cfg.locador_cpf)}, com endereço na #{v(@cfg.locador_endereco)}." ],
      [ "LOCATÁRIO", "<b>#{v(@c.inquilino)}</b>, #{qualificacao(@c.inquilino_nacionalidade, @c.inquilino_estado_civil, @c.inquilino_profissao)}, " \
                     "CPF #{v(@c.inquilino_cpf)}, RG #{v(@c.inquilino_rg)}, com endereço na #{endereco_da_kitnet}." ]
    ]
    if com_fiador?
      lista << [ "FIADOR", "<b>#{v(@c.fiador)}</b>, #{qualificacao(@c.fiador_nacionalidade, @c.fiador_estado_civil, @c.fiador_profissao)}, " \
                           "CPF #{v(@c.fiador_cpf)}, identidade #{v(@c.fiador_rg)}, com endereço em #{v(@c.fiador_endereco)}." ]
    end
    lista
  end

  def com_fiador? = !@c.sem_fiador_no_contrato?

  def clausulas
    inicio = @c.data_inicio ? I18n.l(@c.data_inicio) : VAZIO
    termino = @c.data_fim ? I18n.l(@c.data_fim) : VAZIO
    taxa = @cfg.taxa_limpeza

    lista = [
      [ :titulo, "CLÁUSULAS E CONDIÇÕES" ],
      [ :clausula, "O valor do aluguel ora avençado é #{dinheiro(@c.valor)} (#{Extenso.reais(@c.valor)}) o qual deverá ser pago até o dia " \
                   "#{@c.dia_vencimento} (#{Extenso.numero(@c.dia_vencimento)}) de cada mês, #{v(@cfg.forma_pagamento)}." ],
      [ :clausula, "O prazo de locação é de #{@c.duracao_meses} (#{Extenso.numero(@c.duracao_meses)}) meses, com início no dia #{inicio} e término no dia #{termino}. " \
                   "Sendo que, após um ano, o locatário poderá rescindir esta locação sem multa, desde que avise expressamente ao locador com antecedência " \
                   "mínima de 30 dias. Caso haja rescisão unilateral pelo locatário antes de completar um ano, será cobrada uma multa de um mês de aluguel." ],
      [ :clausula, "O valor da locação será reajustado anualmente de acordo com os índices governamentais. Sendo que o índice apurado na data do reajuste " \
                   "será aplicado sobre o valor do aluguel da época." ],
      [ :clausula, "A destinação do imóvel locado é para fim residencial para uma pessoa, vedado expressamente o uso do mesmo para outros fins, sendo também " \
                   "vedado transferir, sublocar, ceder ou emprestar, a qualquer título, no todo ou em parte o imóvel locado: a não ser através de prévio " \
                   "consentimento expresso do locador. Cabe ainda ressaltar que não é também permitido crianças até 12 anos nas dependências do imóvel devido " \
                   "a condições de acessibilidade inadequadas para elas, bem como, é proibido qualquer tipo de animais nas dependências do referido imóvel." ],
      [ :clausula, "É vedado ao locatário fumar nas áreas comuns, o uso de ar condicionado fixo, o uso de aparelho sonoro em alto volume para não incomodar " \
                   "a vizinhança, bem como não jogar papel ou absorvente dentro do vaso sanitário e não furar a cerâmica." ],
      [ :clausula, "Não é permitido ao locatário manter em depósito, substância ilícita, tóxica ou inflamável dentro do imóvel objeto desta locação." ],
      [ :clausula, "São de inteira responsabilidade do locatário, <b>o aluguel e a conta de luz</b>, sendo esta última, medida separadamente via medidor " \
                   "individual, já no caso da tarifa de água, está inclusa no valor da locação." ],
      [ :clausula, "Os aluguéis ou encargos convencionados não pagos no seu vencimento terão seus valores acrescidos de <u>multa de 10%, mais juros de 1% " \
                   "(um por cento) ao mês se o atraso for superior a trinta dias</u>, ficarão também sujeitos a correção monetária, de acordo com as normas governamentais." ],
      [ :clausula, "Fica esclarecido que estando o locatário de posse do aluguel e encargos concernentes ao último mês da locação, não é prova suficiente " \
                   "de que tenha quitado os débitos anteriores." ]
    ]

    if com_fiador?
      lista += [
        [ :titulo, "DA RESPONSABILIDADE DOS FIADORES" ],
        [ :clausula, "O fiador é o principal pagador do locatário, em qualquer falta ou impontualidade do mesmo, ficará solidariamente responsável pelo " \
                     "cumprimento de todas as cláusulas contratuais e obrigações legais, perdurando tais responsabilidades legais até a devolução e quitação " \
                     "geral de todas despesas inerentes ao imóvel." ],
        [ :clausula, "O fiador devedor solidário declara renunciar expressamente desde a assinatura deste contrato, ao direito de restringir a fiança no " \
                     "prazo ajustado ou nas prorrogações expressas e tácitas, assim renunciando desde logo a faculdade que lhe é assegurada pela legislação em vigor." ],
        [ :clausula, "Nas hipóteses de morte, falência ou insolvência do fiador, obriga-se o locatário, a imediata apresentação de novo fiador." ]
      ]
    end

    lista += [
      [ :titulo, "DA RESCISÃO" ],
      [ :clausula, "Considerar-se-á rescindido o presente contrato, de pleno direito, sem qualquer interpelação judicial ou extrajudicial, nos seguintes casos:" ],
      [ :item, "a) Incêndio ou acidente que obrigue o prédio a obras;" ],
      [ :item, "b) Desapropriação imposta pelas autoridades;" ],
      [ :item, "c) Falência do locatário ou seu representante legal;" ],
      [ :item, "d) Inadimplemento do locatário por mais de 30 (trinta) dias;" ],
      [ :item, "e) Fim da vigência do contrato." ],
      [ :clausula, "A parte que infringir obrigação legal ou cometer infração a obrigação contratual fica sujeita ao pagamento de uma multa correspondente " \
                   "a 20% (vinte por cento) do valor total do contrato, incluídos em tal valor os reajustes previstos, sendo o valor da multa desde logo " \
                   "exigível, e no caso de procedimento judicial, aos acréscimos de juros de mora, correção monetária, custas judiciais e honorários " \
                   "advocatícios, sobre o valor da causa e demais despesas atinentes a demanda, cujo valor será sempre líquido e certo, considerando " \
                   "todas as despesas de aluguel, consertos, conservação e limpeza, luz, desde que vinculados ao presente contrato." ],
      [ :titulo, "DA CONSERVAÇÃO - BENFEITORIA - RESTITUIÇÃO - VISTORIAS" ],
      [ :clausula, "O locatário, salvo as obras que importem na segurança do imóvel (benfeitorias necessárias), obriga-se a fazer com solidez e perfeição, " \
                   "todos os reparos e consertos de que necessite o imóvel objeto deste contrato desde que sejam oriundas de sua manutenção (conservação)." ],
      [ :clausula, "É vedado modificar, pintar, decorar (ex: papel de parede) o imóvel em questão sem a anuência expressa do locador." ]
    ]
    if taxa.to_d.positive?
      lista << [ :clausula, "Como o locatário recebeu o imóvel objeto deste contrato totalmente pintado da cor gelo, haverá uma taxa de limpeza e pintura " \
                            "no valor de #{dinheiro(taxa)}, por ocasião da assinatura deste instrumento contratual. O que liberará o locatário da " \
                            "responsabilidade de tais serviços por ocasião de sua saída no fim do contrato." ]
    end
    lista + [
      [ :clausula, "O locatário obriga-se a manter o imóvel locado em boas condições de higiene e limpeza e em perfeito estado de conservação e " \
                   "funcionamento, obrigando-se pela sua completa reparação no caso de <b>mau uso</b> quando termine, ou rescindindo este contrato, por " \
                   "qualquer motivo, de modo a entregar o imóvel ao locador em perfeitas condições de uso, ficando sem qualquer direito a retenção ou " \
                   "indenização por quaisquer benfeitorias, salvo as necessárias, as quais se incorporarão ao imóvel locado." ],
      [ :clausula, "O locador a qualquer tempo, por si ou por pessoa de sua confiança, poderá examinar ou vistoriar o imóvel locado quando assim o " \
                   "entender, desde que comunique ao locatário com antecedência mínima de sete dias." ],
      [ :clausula, "Para todas as questões oriundas do presente contrato, fica eleito o foro de #{v(@cfg.foro)}." ],
      [ :clausula, "E por se acharem de pleno e comum acordo, de tudo quanto neste instrumento de locação foi lavrado, as partes contratantes, na " \
                   "presença de duas testemunhas abaixo, assinaram este compromisso em duas vias de igual teor." ]
    ]
  end

  def assinaturas(pdf)
    data = "_____ de ______________ de ________"
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

  def rodape(pdf)
    pdf.repeat(:all) do
      pdf.bounding_box([ 0, -18 ], width: pdf.bounds.width, height: 20) do
        pdf.font_size(9) { pdf.text "Rubricas: ______  ______  ______", align: :right, color: "666666" }
      end
    end
    pdf.number_pages "Página <page> de <total>", at: [ 0, -20 ], size: 9, color: "666666"
  end
end
