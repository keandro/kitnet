# Conta onde os locatários pagam: banco, agência, conta e chave Pix.
class ContaPagamento < ApplicationRecord
  # Bancos mais comuns (código COMPE), para completar o nome pelo código.
  BANCOS = {
    "001" => "Banco do Brasil", "021" => "Banestes", "033" => "Santander", "041" => "Banrisul", "070" => "BRB",
    "077" => "Banco Inter", "104" => "Caixa Econômica Federal", "197" => "Stone", "208" => "BTG Pactual",
    "212" => "Banco Original", "237" => "Bradesco", "260" => "Nubank", "290" => "PagBank", "323" => "Mercado Pago",
    "336" => "C6 Bank", "341" => "Itaú", "380" => "PicPay", "403" => "Cora", "422" => "Safra",
    "748" => "Sicredi", "756" => "Sicoob"
  }.freeze

  normalizes :titular, :banco_nome, :agencia, :conta, :chave_pix, with: ->(texto) { texto.squish.presence }
  # "1" e "001" são o mesmo banco.
  normalizes :banco_codigo, with: ->(codigo) {
    digitos = codigo.gsub(/\D/, "")
    digitos.rjust(3, "0") if digitos.present?
  }

  validates :titular, presence: true
  validates :banco_codigo, format: { with: /\A\d{3}\z/, message: "deve ter 3 números" }, allow_nil: true
  validate :tem_como_pagar

  scope :ordenadas, -> { order(:titular, :banco_nome) }

  def banco
    [ banco_codigo, banco_nome ].compact.join(" – ").presence
  end

  private

  def tem_como_pagar
    errors.add(:base, "Informe a chave Pix ou a agência e a conta") if chave_pix.blank? && (agencia.blank? || conta.blank?)
  end
end
