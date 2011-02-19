module UniFreire
  module Graphics
    class GeralResultadoInfantilFundamental

      INFANTIL_DATA="Educação Infantil"
      FUNDAMENTAL_DATA="Ensino Fundamental"



      def self.create_data(hash_reports)
        legend=[]
        colors = %w(#6666ff #cccc66 #ffd320)
        connection = ActiveRecord::Base.connection

        connection.execute "DELETE FROM report_data WHERE institution_id = 0 "

        connection.execute "
          insert into report_data
          select 0,'#{INFANTIL_DATA}',2,segment_name,segment_order,
            avg(score) as media,dimension,indicator,question
            from comparable_answers ca INNER JOIN institutions_service_levels isl
            ON isl.institution_id = ca.institution_id
            where isl.service_level_id = 2 and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question
          "
        legend << {:name=>INFANTIL_DATA,:color=>colors[0]}

        connection.execute "
          insert into report_data
            select 0,'#{FUNDAMENTAL_DATA}',3,segment_name,segment_order,
              avg(score) as media,dimension,indicator,question
              from comparable_answers ca INNER JOIN institutions_service_levels isl
              ON isl.institution_id = ca.institution_id
              where isl.service_level_id = 3 and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question"
        legend << {:name=>FUNDAMENTAL_DATA,:color=>colors[1]}

        connection.execute "update report_data set segment_name='Funcionários', segment_order=4  where segment_name like 'Func%' and institution_id = 0 "
        connection.execute "update report_data set segment_name='Professores', segment_order=2 where segment_name like 'Prof%' and institution_id = 0 "
        connection.execute "delete from report_data where segment_name = 'Educandos' and institution_id = 0 and item_order=2"

        remove_invalid_indicators_and_dimensions(hash_reports)

        connection.execute "
          insert into report_data
            select 0,'#{INFANTIL_DATA}',2,'Média Geral',0,
              avg(score) as media,dimension,indicator,question
            from report_data where item_order=2
            group by dimension,indicator,question"

        connection.execute "
          insert into report_data
            select 0,'#{FUNDAMENTAL_DATA}',3,'Média Geral',0,
            avg(score) as media,dimension,indicator,question
            from report_data where item_order=3
            group by dimension,indicator,question"
        legend
      end


      def self.create_dimension( dimension, size, legend, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT segment_name,sum_type,AVG(media) as new_media from
            (SELECT segment_name, item_order, segment_order,
                 sum_type, indicator, AVG(score) AS media
          FROM   report_data
          WHERE  dimension = #{dimension} AND score > 0
          GROUP  BY segment_order, item_order,indicator) a
          GROUP BY segment_order, item_order"
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :marker_font_size => 12,
                                :no_data_message=> "\n Não há dados \npara esta \n dimensão")
        graphic.generate(result,legend,"geral_resultado_infantil_fundamental_dimensao_#{dimension}")
      end

      def self.create_indicators (dimension, size, legend, title=nil)
        connection = ActiveRecord::Base.connection
        indicators_result = connection.execute("select indicator from comparable_answers
          where dimension=#{dimension} group by indicator;")
        indicators = []
        indicators_result.each {|i| indicators << i[0]}
        graphics = []

        indicators.each do |indicator_id|
          result = connection.execute "
            SELECT segment_name,sum_type,AVG(media) as new_media from
              (SELECT segment_name,
                 item_order,
                 segment_order,
                 sum_type, indicator,
                 AVG(score) AS media
              FROM   report_data
              WHERE  dimension = #{dimension}
                 AND indicator = #{indicator_id}
                 AND score > 0
              GROUP  BY segment_order, item_order,indicator) a
              GROUP BY segment_order, item_order"

          if result.num_rows > 0
            graphic = UniFreire::Graphics::Generator.new(:size => size, :title => "Indicador #{dimension}.#{indicator_id}",
                    :no_data_message=> "\n Não há dados \n para o \n indicador #{dimension}.#{indicator_id}")
            graphics << graphic.generate(result,legend,
                   "resultado_infantil_fundamental_dimensao_indicador_#{dimension}_#{indicator_id}")
          end
        end
        graphics
      end

      def self.remove_invalid_indicators_and_dimensions(hash_reports)

        connection=ActiveRecord::Base.connection
        hash_reports.each_pair do |key,hash|
          connection.execute("delete from report_data where dimension=#{hash[:invalid_dimensions]}
                      and item_order = #{hash[:number]}")
          i=1
          hash[:invalid_indicators].each do |arr|
            in_clause = arr.join(",")
            if in_clause.size > 0
              connection.execute("delete from report_data where dimension=#{i}
                      and item_order = #{hash[:number]} and indicator in (#{in_clause})")
            end
            i+=1
          end
        end

      end

    end
  end
end

