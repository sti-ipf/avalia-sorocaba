module UniFreire
  module Graphics
    class ResultadosIndicadores
      
      def self.create(institution_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        graphics = []

        (1..11).each do |dimension_id|
          result = connection.execute "
            SELECT CONCAT(dimension,'.',indicator) as i, year, AVG(score) AS media 
            FROM   comparable_answers 
            WHERE  institution_id = #{institution_id} AND dimension = #{dimension_id}
            GROUP  BY indicator, year; 
            "
          graphic = 
            if dimension_id == 11
              UniFreire::Graphics::Generator.new(:size => '960x400', :title => "Dimensão #{dimension_id}")
            else
              UniFreire::Graphics::Generator.new(:size => size, :title => "Dimensão #{dimension_id}")
            end
          colors={"2008"=>0,"2009"=>1,"2010"=>2,"color"=>Generator::COLORS[:three]}
          graphics << graphic.generate(result,colors)
        end
        graphics
      end

    end
  end
end

