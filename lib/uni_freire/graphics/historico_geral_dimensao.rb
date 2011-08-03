module UniFreire
  module Graphics
    class HistoricoGeralDimensao
      def self.create( size, legend,hash_report, title=nil)
        connection = ActiveRecord::Base.connection
        complete_clause=[]
        dimension=1
        hash_report[:invalid_indicators].each do |t|
          in_clause = t.join(",")
          complete_clause << " (dimension=#{dimension}) and (indicator in (#{in_clause})) " if in_clause.size > 0
          dimension += 1
        end
        clause=""
        clause=" where NOT (#{complete_clause.join(" or ")})" if complete_clause.size > 0

        result = connection.execute "
          SELECT dimension,year, avg(media) as new_media from
          (SELECT ca.dimension as dimension, ca.indicator as indicator, ca.year as year, AVG(ca.score) AS media
          FROM   comparable_answers ca INNER JOIN institutions_year_history iyh
          ON iyh.institution_id = ca.institution_id and iyh.year=ca.year
          WHERE  score > 0 and iyh.level_type = #{hash_report[:number]} and
          dimension not in (#{hash_report[:invalid_dimensions]})
          GROUP BY dimension, indicator, year) a #{clause} GROUP BY dimension,year"
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :marker_font_size => 12,
                                :no_data_message=> "\n Não há dados \npara esta \n dimensão")
        graphic.generate(result,legend,"historico_geral_dimensao_#{hash_report[:number]}")
      end

    end
  end
end

