module UniFreire
  module Graphics
    class GeralResultadoInfantil

      INFANTIL_PARCIAL_DATA="Infantil Parcial"
      INFANTIL_INTEGRAL_DATA="Infantil Integral"
      INFANTIL_INTEGRAL_PARCIAL_DATA="Infantil Integral + Parcial"

      INFANTIL_PARCIAL=2
      INFANTIL_INTEGRAL=3
      INFANTIL_INTEGRAL_PARCIAL=1

      def self.execute_insert_query(data,num_type,color,order)
          ActiveRecord::Base.connection.execute "
          insert into report_data
          select 0,'#{data}',#{order},segment_name,segment_order,
            avg(score) as media,dimension,indicator,question
            from comparable_answers ca INNER JOIN institutions i
            ON i.id = ca.institution_id
            where i.infantil_type = #{num_type} and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question
          "
        {:name=>data,:color=>color}
      end

      def self.execute_average_query(data,order)
          ActiveRecord::Base.connection.execute "
          insert into report_data
            select 0,'#{data}',#{order},'Média Geral',0,
              avg(score) as media,dimension,indicator,question
            from report_data where item_order=#{order}
            group by dimension,indicator,question"
      end



      def self.create_data(hash_reports)
        legend=[]
        colors = %w(#ff9966 #66cc66 #ffff66)
        connection = ActiveRecord::Base.connection

        connection.execute "DELETE FROM report_data WHERE institution_id = 0 "

        legend << execute_insert_query(INFANTIL_PARCIAL_DATA,INFANTIL_PARCIAL,colors[0],1)
        legend << execute_insert_query(INFANTIL_INTEGRAL_DATA,INFANTIL_INTEGRAL,colors[1],2)
        legend << execute_insert_query(INFANTIL_INTEGRAL_PARCIAL_DATA,INFANTIL_INTEGRAL_PARCIAL,colors[2],3)

        connection.execute "update report_data set segment_name='Funcionários', segment_order=4   where segment_name like 'Func%' and institution_id = 0"
        connection.execute "update report_data set segment_name='Professores', segment_order=2  where segment_name like 'Prof%' and institution_id = 0"
        connection.execute "delete from report_data where segment_name = 'Educandos' and institution_id = 0 and item_order=2"

        remove_invalid_indicators_and_dimensions(hash_reports[:infantil])

        execute_average_query(INFANTIL_PARCIAL_DATA,1)
        execute_average_query(INFANTIL_INTEGRAL_DATA,2)
        execute_average_query(INFANTIL_INTEGRAL_PARCIAL_DATA,3)

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
        graphic.generate(result,legend,"geral_resultado_infantil_dimensao_#{dimension}")
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
                   "resultado_infantil_dimensao_indicador_#{dimension}_#{indicator_id}")
          end
        end
        graphics
      end

      def self.remove_invalid_indicators_and_dimensions(hash)
        connection=ActiveRecord::Base.connection
        connection.execute("delete from report_data where dimension=#{hash[:invalid_dimensions]}
                      and institution_id=0")
        i=1
        hash[:invalid_indicators].each do |arr|
          in_clause = arr.join(",")
          if in_clause.size > 0
            connection.execute("delete from report_data where dimension=#{i}
                    and institution_id=0 and indicator in (#{in_clause})")
          end
          i+=1
        end

      end

    end
  end
end

