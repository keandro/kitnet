module ApplicationHelper
  # Status colors are reserved by meaning (good/warning/critical/info/neutral)
  # and always paired with an icon + label — never color alone.
  TONE_CLASSES = {
    good: "bg-emerald-50 text-emerald-700 ring-emerald-600/20 dark:bg-emerald-400/10 dark:text-emerald-400 dark:ring-emerald-400/20",
    warning: "bg-amber-50 text-amber-700 ring-amber-600/20 dark:bg-amber-400/10 dark:text-amber-400 dark:ring-amber-400/20",
    critical: "bg-rose-50 text-rose-700 ring-rose-600/20 dark:bg-rose-400/10 dark:text-rose-400 dark:ring-rose-400/20",
    info: "bg-blue-50 text-blue-700 ring-blue-600/20 dark:bg-blue-400/10 dark:text-blue-400 dark:ring-blue-400/20",
    neutral: "bg-slate-100 text-slate-600 ring-slate-500/20 dark:bg-white/5 dark:text-slate-300 dark:ring-white/10"
  }.freeze

  TONE_ICONS = {
    good: :check_circle,
    warning: :exclamation_triangle,
    critical: :x_circle,
    info: :clock,
    neutral: :clock
  }.freeze

  def status_badge(label, tone:, icon: nil)
    classes = TONE_CLASSES.fetch(tone, TONE_CLASSES[:neutral])
    icon_name = icon || TONE_ICONS.fetch(tone, :clock)
    tag.span class: "inline-flex items-center gap-1 whitespace-nowrap rounded-full px-2.5 py-1 text-xs font-medium ring-1 ring-inset #{classes}" do
      concat icon(icon_name, css_class: "size-3.5")
      concat label
    end
  end


  ICON_CHIP_CLASSES = {
    primary: "bg-indigo-50 text-indigo-600 dark:bg-indigo-400/10 dark:text-indigo-400",
    good: "bg-emerald-50 text-emerald-600 dark:bg-emerald-400/10 dark:text-emerald-400",
    warning: "bg-amber-50 text-amber-600 dark:bg-amber-400/10 dark:text-amber-400",
    critical: "bg-rose-50 text-rose-600 dark:bg-rose-400/10 dark:text-rose-400",
    info: "bg-blue-50 text-blue-600 dark:bg-blue-400/10 dark:text-blue-400",
    neutral: "bg-slate-100 text-slate-600 dark:bg-white/5 dark:text-slate-300"
  }.freeze

  def icon_chip_classes(tone)
    ICON_CHIP_CLASSES.fetch(tone, ICON_CHIP_CLASSES[:primary])
  end

  FIELD_BASE_CLASSES = "mt-1.5 block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm ring-1 ring-inset placeholder:text-slate-400 focus:ring-2 focus:ring-inset focus:outline-none dark:bg-white/5 dark:text-white"
  FIELD_OK_CLASSES = "ring-slate-300 focus:ring-indigo-600 dark:ring-white/10 dark:focus:ring-indigo-500"
  FIELD_ERROR_CLASSES = "ring-rose-400 focus:ring-rose-500 dark:ring-rose-400/50"
  LABEL_CLASSES = "block text-sm font-medium text-slate-700 dark:text-slate-300"

  def field_classes(object, attribute)
    "#{FIELD_BASE_CLASSES} #{object.errors[attribute].any? ? FIELD_ERROR_CLASSES : FIELD_OK_CLASSES}"
  end

  def label_classes
    LABEL_CLASSES
  end

  # Campo de dinheiro com "R$" à frente; o money_controller formata enquanto
  # digita (1.234,56) e o model converte de volta com ValorMonetario.
  def money_field(form, attribute, data: {}, decimais: 2)
    valor = form.object.public_send(attribute)
    valor = format_money(valor, precision: decimais) if valor.is_a?(Numeric)

    tag.div(class: "relative") do
      tag.span("R$", class: "pointer-events-none absolute inset-y-0 left-3 mt-1.5 flex items-center text-sm text-slate-400") +
        form.text_field(attribute, value: valor, inputmode: "numeric", autocomplete: "off", placeholder: format_money(0, precision: decimais),
                        class: "#{field_classes(form.object, attribute)} pl-10",
                        data: { controller: "money", action: "input->money#format", money_decimais_value: decimais }.merge(data))
    end
  end

  # 1234.5 -> "1.234,50" (sem o "R$"), o formato do money_field.
  def format_money(valor, precision: 2)
    number_with_precision(valor, precision: precision, delimiter: ".", separator: ",")
  end

  # Áreas que ficam na barra de baixo do celular.
  def menu_principal
    [
      { rotulo: "Finanças", curto: "Finanças", caminho: financas_path, icone: :chart },
      { rotulo: "Pagamentos", curto: "Pagamentos", caminho: pagamentos_path, icone: :cash },
      { rotulo: "Energia", curto: "Energia", caminho: energia_path, icone: :bolt },
      { rotulo: "Energia solar", curto: "Solar", caminho: energia_solar_path, icone: :sun }
    ]
  end

  # Barra lateral (computador), em grupos separados por uma linha.
  def menu_barra_lateral
    [
      [ [ "Início", root_path, :home ] ],
      [ [ "Finanças", financas_path, :chart ], [ "Pagamentos", pagamentos_path, :cash ], [ "Kitnets", unidades_path, :grid ] ],
      [ [ "Contratos", contratos_path, :document ], [ "Ocupação", ocupacao_path, :users ], [ "Contas para pagamento", contas_pagamento_path, :banco ] ],
      [ [ "Energia", energia_path, :bolt ], [ "Energia solar", energia_solar_path, :sun ] ],
      [ [ "Backup", backups_path, :arquivo ] ]
    ]
  end

  # Áreas do "Mais" (no celular).
  def menu_mais
    [
      { rotulo: "Início", caminho: root_path, icone: :home, tom: :primary, descricao: "Avisos e resumo do ano" },
      { rotulo: "Contratos", caminho: contratos_path, icone: :document, tom: :info, descricao: "Contratos de aluguel e contrato para assinar" },
      { rotulo: "Ocupação", caminho: ocupacao_path, icone: :users, tom: :warning, descricao: "Kitnets ocupadas e livres" },
      { rotulo: "Kitnets", caminho: unidades_path, icone: :grid, tom: :primary, descricao: "Valor base e histórico de pagamentos" },
      { rotulo: "Contas para pagamento", caminho: contas_pagamento_path, icone: :banco, tom: :good, descricao: "Banco, agência, conta e chave Pix" },
      { rotulo: "Backup", caminho: backups_path, icone: :arquivo, tom: :neutral, descricao: "Exportar, importar e cópias" }
    ]
  end

  def menu_ativo?(path)
    current_page?(path) || request.path.start_with?("#{path}/")
  end

  def menu_mais_ativo?
    current_page?(mais_path) || menu_mais.any? { |item| item[:caminho] != root_path && menu_ativo?(item[:caminho]) }
  end

  def sidebar_nav_link(label, path, icon_name)
    classes = if menu_ativo?(path)
      "bg-indigo-50 text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300"
    else
      "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-400 dark:hover:bg-white/5 dark:hover:text-white"
    end

    link_to path, class: "group flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors #{classes}",
                  aria: { current: (menu_ativo?(path) ? "page" : nil) } do
      concat icon(icon_name, css_class: "size-5 shrink-0")
      concat label
    end
  end

  def bottom_nav_link(label, path, icon_name, ativo: menu_ativo?(path))
    link_to path, class: "flex flex-col items-center gap-1 px-1 pt-2 pb-2.5 text-[11px] font-medium #{ativo ? "text-indigo-600 dark:text-indigo-400" : "text-slate-500 dark:text-slate-400"}",
                  aria: { current: (ativo ? "page" : nil) } do
      concat tag.span(icon(icon_name, css_class: "size-5"), class: "flex h-7 w-12 items-center justify-center rounded-full #{"bg-indigo-50 dark:bg-indigo-500/15" if ativo}")
      concat tag.span(label, class: "truncate")
    end
  end

  # Logotipo: a casinha do ícone num quadrado com degradê.
  def marca_lf_kitnets(tamanho: "size-8")
    tag.span(icon(:home, css_class: "size-[60%]"),
             class: "flex #{tamanho} shrink-0 items-center justify-center rounded-lg bg-gradient-to-br from-indigo-500 to-violet-600 text-white shadow-sm shadow-indigo-500/30")
  end
end
