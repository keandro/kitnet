module KitnetsHelper
  def andar_label(chave)
    return "Térreo" if chave == "0"
    return "#{chave}º andar" if chave =~ /\A\d+\z/

    "Bloco #{chave}"
  end
end
