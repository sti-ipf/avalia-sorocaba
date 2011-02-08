module UniFreire
  module Graphics
    class Indicadores
      
      def self.create(institution_id, dimension_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT dimension, indicator, year, AVG(score) AS media 
          FROM   comparable_answers 
          WHERE  institution_id = #{institution_id} AND dimension = #{dimension_id}
          GROUP  BY year, indicator; 
          "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title)
        graphic.generate(result)
      end
      
    end
  end
end
