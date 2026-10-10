# frozen_string_literal: true

class PagamentoPolicy < ApplicationPolicy
  def pagar?
    update?
  end
end
