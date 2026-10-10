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
    tag.span class: "inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium ring-1 ring-inset #{classes}" do
      concat icon(icon_name, css_class: "size-3.5")
      concat label
    end
  end

  PAGAMENTO_TONES = { pago: :good, vencido: :critical, pendente: :warning, sem_pagamento: :neutral }.freeze
  UNIDADE_TONES = { livre: :good, ocupada: :info, manutencao: :warning }.freeze
  CONTRATO_TONES = { ativo: :good, encerrado: :neutral, cancelado: :critical }.freeze
  CATEGORIA_TONES = { morador: :info, fiador: :neutral, ambos: :good, sem_contrato_ativo: :neutral }.freeze

  def status_pagamento_badge(status)
    status_badge(t("pagamento.status.#{status}"), tone: PAGAMENTO_TONES.fetch(status.to_sym, :neutral))
  end

  def unidade_status_badge(status)
    status_badge(t("unidade.status.#{status}"), tone: UNIDADE_TONES.fetch(status.to_sym, :neutral))
  end

  CARD_ACCENT_CLASSES = {
    good: "border-emerald-200 dark:border-emerald-400/20",
    warning: "border-amber-200 dark:border-amber-400/20",
    critical: "border-rose-200 dark:border-rose-400/20",
    info: "border-blue-200 dark:border-blue-400/20",
    neutral: "border-slate-200 dark:border-white/10"
  }.freeze

  def unidade_card_classes(status)
    tone = UNIDADE_TONES.fetch(status.to_sym, :neutral)
    CARD_ACCENT_CLASSES.fetch(tone, CARD_ACCENT_CLASSES[:neutral])
  end

  def contrato_status_badge(status)
    status_badge(t("contrato.status.#{status}"), tone: CONTRATO_TONES.fetch(status.to_sym, :neutral))
  end

  def pessoa_categoria_badge(categoria)
    status_badge(t("pessoa.categoria.#{categoria}"), tone: CATEGORIA_TONES.fetch(categoria.to_sym, :neutral))
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

  FIELD_BASE_CLASSES = "mt-1 block w-full rounded-lg border px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 dark:bg-slate-900 dark:text-white"
  FIELD_OK_CLASSES = "border-slate-300 focus:border-indigo-500 focus:ring-indigo-500 dark:border-white/10"
  FIELD_ERROR_CLASSES = "border-rose-400 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-400/50"
  LABEL_CLASSES = "block text-sm font-medium text-slate-700 dark:text-slate-300"

  def field_classes(object, attribute)
    "#{FIELD_BASE_CLASSES} #{object.errors[attribute].any? ? FIELD_ERROR_CLASSES : FIELD_OK_CLASSES}"
  end

  def label_classes
    LABEL_CLASSES
  end

  # Campo de dinheiro com "R$" à frente; o money_controller formata enquanto
  # digita (1.234,56) e o model converte de volta com ValorMonetario.
  def money_field(form, attribute)
    valor = form.object.public_send(attribute)
    valor = number_with_precision(valor, precision: 2, delimiter: ".", separator: ",") if valor.is_a?(Numeric)

    tag.div(class: "relative") do
      tag.span("R$", class: "pointer-events-none absolute inset-y-0 left-3 mt-1 flex items-center text-sm text-slate-500 dark:text-slate-400") +
        form.text_field(attribute, value: valor, inputmode: "numeric", autocomplete: "off", placeholder: "0,00",
                        class: "#{field_classes(form.object, attribute)} pl-10",
                        data: { controller: "money", action: "input->money#format" })
    end
  end

  def sidebar_nav_link(label, path, icon_name)
    active = current_page?(path) || (path != root_path && request.path.start_with?(path))
    classes = if active
      "bg-indigo-50 text-indigo-700 dark:bg-indigo-400/10 dark:text-indigo-400"
    else
      "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-white/5 dark:hover:text-white"
    end

    link_to path, class: "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors #{classes}" do
      concat icon(icon_name, css_class: "size-5 shrink-0")
      concat label
    end
  end
end
