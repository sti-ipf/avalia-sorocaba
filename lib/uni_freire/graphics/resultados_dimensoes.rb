module UniFreire
  module Graphics
    class ResultadosDimensoes

      def self.create(institution_id, size, legend,title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT dimension, year, AVG(score) AS media
          FROM   comparable_answers
          WHERE  institution_id = #{institution_id}
          GROUP  BY dimension, year;
        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title)
        graphic.generate(result,legend,
          "#{institution_id}_resultado_dimensoes")
      end
       #Generator::COLORS[:three][colors[l]]
    end
  end
end

