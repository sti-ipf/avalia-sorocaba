require 'spec_helper'

describe UniFreire::Graphics::Generator do 
  before(:each) do
    @generator = UniFreire::Graphics::Generator.new(:size => '600x400', :title => nil)
    @generator_with_title_and_wide = UniFreire::Graphics::Generator.new(:size => '960x400', :title => 'Title Test')
    @data = [["1", "2008", "4.5577"],["1", "2009", "1.3"],["1", "2010", "2.1"]]
    @no_data = []
  end
  
  describe 'generate' do
    it 'deve salvar o gráfico' do
      file_name = @generator.generate(@data)
      file_name.include?(".jpg").should be_true
      File.exists?(file_name).should == true
    end
    
    it 'deve salvar o gráfico com o nome informado' do
      file_name = @generator.generate(@data, 'grafico_de_teste')
      file_name.include?("grafico_de_teste.jpg").should be_true
      File.exists?(file_name).should == true
    end
    
    it 'deve salvar o gráfico sem dados quando o array de dados está vazio' do
      file_name = @generator.generate(@no_data, 'grafico sem dados')
      file_name.include?("grafico sem dados.jpg").should be_true
      File.exists?(file_name).should == true
    end

    it 'deve salvar o gráfico com título e largo' do
      file_name = @generator_with_title_and_wide.generate(@data, 'gráfico com título e largo')
      file_name.include?("gráfico com título e largo.jpg").should be_true
      File.exists?(file_name).should == true
    end    
    
    
  end
end
