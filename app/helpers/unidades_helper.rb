module UnidadesHelper
  # Primeiro dígito do nome da kitnet = andar ("001" -> térreo, "101" -> 1º andar).
  def andar_label(chave)
    return "Térreo" if chave == "0"
    return "#{chave}º andar" if chave =~ /\A\d+\z/

    "Bloco #{chave}"
  end
end
