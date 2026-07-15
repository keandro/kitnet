module ApplicationHelper
  STATUS_BADGE_CLASSES = {
    pago: "bg-green-100 text-green-700",
    vencido: "bg-red-100 text-red-700",
    pendente: "bg-yellow-100 text-yellow-700",
    sem_pagamento: "bg-gray-100 text-gray-700"
  }.freeze

  def status_pagamento_badge(status)
    classes = STATUS_BADGE_CLASSES.fetch(status.to_sym, "bg-gray-100 text-gray-700")
    tag.span t("pagamento.status.#{status}"), class: "inline-block px-2 py-1 rounded-md text-sm font-medium #{classes}"
  end
end
