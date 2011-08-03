require 'spec_helper'

describe UniFreire::Graphics::Indicadores do 
  before(:each) do
    @institution_id = 72
    @dimension_id = 11
    @legends = UniFreire::Graphics::GeralDimensao.create_report_data(
      @institution_id, UniFreire::Reports::RelatorioIndividualSoracaba::COLORS[:five])
  end
  
  it 'deve criar os gráficos' do
    files = UniFreire::Graphics::Indicadores.create(@institution_id, @dimension_id, UniFreire::Reports::SIZE[:default], @legends)
    i = 1
    files.each do |file_name|
      file_name.include?("#{@institution_id}_dimensao_indicador_#{@dimension_id}_#{i}.jpg").should be_true
      File.exists?(file_name).should == true
      i += 1
    end
  end
    
end
