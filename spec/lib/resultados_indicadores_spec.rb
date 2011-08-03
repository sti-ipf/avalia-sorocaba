require 'spec_helper'

describe UniFreire::Graphics::ResultadosIndicadores do 
  before(:each) do
    @institution_id = 72
    @legends = [{:name => "2008", :color => "red"},
                {:name => "2009", :color => "yellow"},
                {:name => "2010", :color => "green"}]
  end
  
  it 'deve criar um gráfico' do
    files = UniFreire::Graphics::ResultadosIndicadores.create(@institution_id, UniFreire::Reports::SIZE[:wide],@legends)
    i = 1
    files.each do |file_name|
      file_name.include?("#{@institution_id}_resultados_indicadores_#{i}.jpg").should be_true
      File.exists?(file_name).should == true
      i += 1
    end

  end
    
end
