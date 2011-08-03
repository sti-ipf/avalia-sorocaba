require 'spec_helper'

describe UniFreire::Graphics::ResultadosDimensoes do 
  before(:each) do
    @institution_id = 72
    @legends = [{:name => "2008", :color => "red"},
                {:name => "2009", :color => "yellow"},
                {:name => "2010", :color => "green"}]
  end
  
  it 'deve criar um gráfico' do
    file_name = UniFreire::Graphics::ResultadosDimensoes.create(@institution_id, UniFreire::Reports::SIZE[:wide],@legends)
    file_name.include?("#{@institution_id}_resultado_dimensoes.jpg").should be_true
    File.exists?(file_name).should == true
  end
    
end
