# Leva os trechos opcionais ("[, RG {locatario_rg}]") para o texto do contrato
# já salvo no banco: troca as linhas de locador, locatário e fiador que ainda
# estão como no texto original. Linhas mudadas à mão ficam como estão.
class CamposOpcionaisNoTextoSalvo < ActiveRecord::Migration[8.1]
  LINHAS = {
    "**LOCADOR –** **{locador}**, {locador_qualificacao}, CPF {locador_cpf}, com endereço na {locador_endereco}." =>
      "**LOCADOR –** **{locador}**[, {locador_qualificacao}][, CPF {locador_cpf}][, com endereço na {locador_endereco}].",
    "**LOCATÁRIO –** **{locatario}**, {locatario_nacionalidade}, {locatario_estado_civil}, {locatario_profissao}, CPF {locatario_cpf}, RG {locatario_rg}, com endereço na {locatario_endereco}." =>
      "**LOCATÁRIO –** **{locatario}**[, {locatario_nacionalidade}][, {locatario_estado_civil}][, {locatario_profissao}][, CPF {locatario_cpf}][, RG {locatario_rg}], com endereço na {locatario_endereco}.",
    "**FIADOR –** **{fiador}**, {fiador_nacionalidade}, {fiador_estado_civil}, {fiador_profissao}, CPF {fiador_cpf}, identidade {fiador_identidade}, com endereço em {fiador_endereco}." =>
      "**FIADOR –** **{fiador}**[, {fiador_nacionalidade}][, {fiador_estado_civil}][, {fiador_profissao}][, CPF {fiador_cpf}][, identidade {fiador_identidade}][, com endereço em {fiador_endereco}]."
  }.freeze

  def up
    select_rows("SELECT id, texto_modelo FROM configuracoes_contrato WHERE texto_modelo IS NOT NULL").each do |id, texto|
      novo = LINHAS.reduce(texto) { |t, (antiga, nova)| t.gsub(antiga, nova) }
      next if novo == texto

      update("UPDATE configuracoes_contrato SET texto_modelo = #{quote(novo)} WHERE id = #{id.to_i}")
    end
  end

  def down
  end
end
