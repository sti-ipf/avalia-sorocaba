module UniFreire
  module Graphics
    class ResultadosDimensoes

      def self.create(institution_id, size, legend,title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT dimension,year, avg(media) as new_media from
          (SELECT dimension,indicator, year, AVG(score) AS media
          FROM   comparable_answers
          WHERE  institution_id = #{institution_id} AND score > 0
          GROUP BY dimension, indicator, year) a
          GROUP BY dimension,year
        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :marker_font_size => 12,
                                    :no_data_message=> "\nNão há dados \n para esta \n instituição")
        graphic.generate(result,legend,
          "#{institution_id}_resultado_dimensoes")
      end
       #Generator::COLORS[:three][colors[l]]
    end
  end
end

