require 'gruff'

require(File.dirname(__FILE__) + "/../config/environment") unless defined? RAILS_ROOT
require 'lib/uni_freire/graphics/base'
require "lib/uni_freire/reports/relatorio_individual_sorocaba/relatorio_individual_sorocaba"

describe "reports" do
  
  it "Gráfico geral da série histórica dos resultados das dimensões" do
      insts = [
        # 9,
        11,
        # 12,
        # 14,
        # 15,
        # 16,
        # 17,
        # 18,
        # 19,
        # 20,
        # 22
      ].each do |id |
       r = UniFreire::Reports::RelatorioIndividualSoracaba.new(id)
       r.report
     end
  end
end
