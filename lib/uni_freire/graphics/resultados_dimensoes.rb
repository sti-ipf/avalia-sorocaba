module UniFreire
  module Graphics
    class ResultadosDimensoes

      def self.create(institution_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT dimension, year, AVG(score) AS media
          FROM   comparable_answers
          WHERE  institution_id = #{institution_id}
          GROUP  BY dimension, year;
        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title)
        colors={"2008"=>0,"2009"=>1,"2010"=>2,"color"=>Generator::COLORS[:three]}
        graphic.generate(result,colors)
      end
       #Generator::COLORS[:three][colors[l]]
    end
  end
end

