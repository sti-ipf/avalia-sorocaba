require 'gruff'

require(File.dirname(__FILE__) + "/../config/environment") unless defined? RAILS_ROOT
require 'lib/uni_freire/graphics/base'

describe "Graphics" do
  
  it "Gráfico geral da série histórica dos resultados das dimensões" do
    g = UniFreire::Graphics::HistoricoGeralDimensao.new(9)
    g.write("/Users/shairon/Desktop/HistoricoGeralDimensao.png").should be_true

  end
    
  it "Gráficos da série histórica dos resultados dos indicadores" do
      resultados = UniFreire::Graphics::ResultadosIndicadores.new(9)
      resultados.graphics.size.should == 11
      resultados.graphics[1].write("/Users/shairon/Desktop/ResultadosIndicadores.png").should be_true
  end
    
    
   it "Gráfico geral da dimensão" do

      g = UniFreire::Graphics::GeralDimensao.new(9,1)
      g.write("/Users/shairon/Desktop/GeralDimensao.png").should be_true
           
    end  
  
  
    it "Gráficos dos Indicadores" do
      
      resultados = UniFreire::Graphics::GraficosIndicadores.new(9,1)
      resultados.graphics.size.should == 5
      resultados.graphics[1].write("/Users/shairon/Desktop/GraficosIndicadores.png").should be_true

end
  
    
end