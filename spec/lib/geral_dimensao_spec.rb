require 'spec_helper'

describe UniFreire::Graphics::GeralDimensao do 
  before(:each) do
    @institution_id = 72
    @dimension_id = 11
    @legends = UniFreire::Graphics::GeralDimensao.create_report_data(
      @institution_id, UniFreire::Reports::RelatorioIndividualSoracaba::COLORS[:five])
  end
  
  it 'deve criar um gráfico' do
    file_name = UniFreire::Graphics::GeralDimensao.create(@institution_id, @dimension_id, UniFreire::Reports::SIZE[:wide], @legends)
    file_name.include?("#{@institution_id}_geral_dimensao_#{@dimension_id}.jpg").should be_true
    File.exists?(file_name).should == true
  end
    
end
