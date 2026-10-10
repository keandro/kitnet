# Validação e formatação de CPF e telefone brasileiros. Os valores são
# guardados só com dígitos.
module DocumentoBrasileiro
  DDDS = %w[
    11 12 13 14 15 16 17 18 19 21 22 24 27 28 31 32 33 34 35 37 38
    41 42 43 44 45 46 47 48 49 51 53 54 55 61 62 63 64 65 66 67 68 69
    71 73 74 75 77 79 81 82 83 84 85 86 87 88 89 91 92 93 94 95 96 97 98 99
  ].freeze

  module_function

  def cpf_valido?(cpf)
    digitos = cpf.to_s.gsub(/\D/, "")
    return false unless digitos.match?(/\A\d{11}\z/) && digitos.chars.uniq.size > 1

    numeros = digitos.chars.map(&:to_i)
    [ 9, 10 ].all? do |tamanho|
      soma = numeros.first(tamanho).each_with_index.sum { |n, i| n * (tamanho + 1 - i) }
      ((soma * 10) % 11) % 10 == numeros[tamanho]
    end
  end

  # Celular: DDD + 9 + 8 dígitos. Fixo: DDD + [2-5] + 7 dígitos.
  def telefone_valido?(telefone)
    digitos = telefone.to_s.gsub(/\D/, "")
    return false unless DDDS.include?(digitos[0, 2])

    digitos.match?(/\A\d{2}9\d{8}\z/) || digitos.match?(/\A\d{2}[2-5]\d{7}\z/)
  end

  def formatar_cpf(cpf)
    digitos = cpf.to_s.gsub(/\D/, "")
    digitos.size == 11 ? digitos.sub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4') : cpf
  end

  def formatar_telefone(telefone)
    digitos = telefone.to_s.gsub(/\D/, "")
    case digitos.size
    when 11 then digitos.sub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    when 10 then digitos.sub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    else telefone
    end
  end
end
