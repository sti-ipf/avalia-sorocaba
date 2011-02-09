class Generationq
  @queue = :generation
  def self.perform (institution_id)
    puts "Vai gerar relatório para a instituição: #{institution_id}"
    UniFreire::Reports::RelatorioIndividualSoracaba.new(institution_id).report
    puts "Relatório gerado"
  end
end

