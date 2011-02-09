require 'spec_helper'

describe UniFreire::Graphics::Generator do 
  before(:each) do
    @generator = UniFreire::Graphics::Generator.new(:size => '700x540', :title => nil)
    @generator_with_title_and_wide = UniFreire::Graphics::Generator.new(:size => '1500x600', :title => 'Title Test')
    @data = [["1", "2008", "4.5577"],["1", "2009", "1.3"],["1", "2010", "2.1"]]
    @no_data = []
    @legend=[{:name => "2008", :color => "red"},
             {:name => "2009", :color => "yellow"},
             {:name => "2010", :color => "green"}]
  end
  
  describe 'generate' do
    it 'deve salvar o gráfico' do
      file_name = @generator.generate(@data, @legend)
      file_name.include?(".jpg").should be_true
      File.exists?(file_name).should == true
    end
    
    it 'deve salvar o gráfico com o nome informado' do
      file_name = @generator.generate(@data, @legend, 'grafico_de_teste')
      file_name.include?("grafico_de_teste.jpg").should be_true
      File.exists?(file_name).should == true
    end
    
    it 'deve salvar o gráfico sem dados quando o array de dados está vazio' do
      file_name = @generator.generate(@no_data, @legend, 'grafico sem dados')
      file_name.include?("grafico sem dados.jpg").should be_true
      File.exists?(file_name).should == true
    end

    it 'deve salvar o gráfico com título e largo' do
      file_name = @generator_with_title_and_wide.generate(@data, @legend, 'gráfico com título e largo')
      file_name.include?("gráfico com título e largo.jpg").should be_true
      File.exists?(file_name).should == true
    end    
    
    
  end
end
