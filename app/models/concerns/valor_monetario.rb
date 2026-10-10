# Aceita valores no formato brasileiro vindos dos formulários ("R$ 1.234,56")
# além do formato decimal comum ("1234.56").
module ValorMonetario
  extend ActiveSupport::Concern

  class_methods do
    def valor_monetario(*atributos)
      atributos.each do |atributo|
        define_method(:"#{atributo}=") do |valor|
          super(ValorMonetario.normalizar(valor))
        end
      end
    end
  end

  def self.normalizar(valor)
    return valor unless valor.is_a?(String) && valor.include?(",")

    valor.gsub(/[^\d,-]/, "").tr(",", ".")
  end
end
