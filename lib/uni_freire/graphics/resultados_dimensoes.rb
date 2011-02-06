module UniFreire
  module Graphics
    class ResultadosDimensoes
      
      def self.create(institution_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT dimensao, ano, SUM(nota) / COUNT(*) AS media
          FROM   all_answers 
          WHERE  id_instituicao = #{institution_id}
          GROUP  BY ano, dimensao; 
        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title)
        graphic.generate(result)
      end
      
    end
  end
end
