module UniFreire
  module Graphics
    class HistoricoGeralIndicador
      def self.create( dimension, size, legend,hash_report, title=nil)
        connection = ActiveRecord::Base.connection
        in_clause = hash_report[:invalid_indicators][dimension - 1].join(",")
        in_clause = " and indicator not in (#{in_clause}) " if in_clause.size > 0
        result = connection.execute "
          SELECT concat(dimension,'.',indicator),year, avg(media) as new_media from
          (SELECT ca.dimension as dimension, ca.indicator as indicator, ca.year as year, AVG(ca.score) AS media
          FROM   comparable_answers ca INNER JOIN institutions_year_history iyh
          ON iyh.institution_id = ca.institution_id and iyh.year=ca.year
          WHERE  score > 0 and iyh.level_type = #{hash_report[:number]} and
          dimension = #{dimension} #{in_clause}
          GROUP BY dimension, indicator, year) a GROUP BY indicator,year"
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :marker_font_size => 12,
                                :no_data_message=> "\n Não há dados \npara esta \n dimensão")
        graphic.generate(result,legend,"historico_geral_indicador_#{dimension}_#{hash_report[:number]}")
      end

    end
  end
end

