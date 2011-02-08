class Generationq
  @queue = :generation
  def self.perform (institution_id)
    UniFreire::Reports::RelatorioIndividualSoracaba.new(institution_id).report
  end
end

