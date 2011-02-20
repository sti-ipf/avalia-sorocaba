module UniFreire
  module Graphics
    class GeralResultadoAgrupamentos

      TEXT="Ambiente Educativo"

      # Id do agrupamento no banco de dados
      INFANTIL_FUNDAMENTAL_INTEGRAL = 62
      INFANTIL_FUNDAMENTAL_PARCIAL = 63
      FUNDAMENTAL_PARCIAL = 64
      FUNDAMENTAL_INTEGRAL = 65
      FUNDAMENTAL_MEDIO = 66

      def self.execute_insert_query(num_type,color)
          ActiveRecord::Base.connection.execute "
          insert into report_data
          select 0,'#{TEXT}',1,segment_name,segment_order,
            avg(score) as media,dimension,indicator,question
            from comparable_answers ca INNER JOIN institutions i
            ON i.id = ca.institution_id
            where i.group_id = #{num_type} and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question
          "
        {:name=>TEXT,:color=>color}
      end

      def self.execute_average_query()
          ActiveRecord::Base.connection.execute "
          insert into report_data
            select 0,'#{TEXT}',1,'Média Geral',0,
              avg(score) as media,dimension,indicator,question
            from report_data where item_order=1
            group by dimension,indicator,question"
      end



      def self.create_data(group, hash_reports)
        legend=[]

        connection = ActiveRecord::Base.connection

        connection.execute "DELETE FROM report_data WHERE institution_id = 0 "

        legend << execute_insert_query(group,"#669933")

        connection.execute "update report_data set segment_name='Funcionários', segment_order=4   where segment_name like 'Func%' and institution_id = 0"
        connection.execute "update report_data set segment_name='Professores', segment_order=2  where segment_name like 'Prof%' and institution_id = 0"
        #connection.execute "delete from report_data where segment_name = 'Educandos' and institution_id = 0 and item_order=2"

        #remove_invalid_indicators_and_dimensions(hash_reports[:infantil])

        execute_average_query()

        legend
      end


      def self.create_dimension( group, dimension, size, legend, title=nil)
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
        graphic.generate(result,legend,"geral_resultado_agrupamento_#{group}_dimensao_#{dimension}")
      end

      def self.create_indicators (group,dimension, size, legend, title=nil)
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
          puts indicator_id
          if result.num_rows > 0
            puts "Achou"
            graphic = UniFreire::Graphics::Generator.new(:size => size, :title => "Indicador #{dimension}.#{indicator_id}",
                    :no_data_message=> "\n Não há dados \n para o \n indicador #{dimension}.#{indicator_id}")
            graphics << graphic.generate(result,legend,
                   "resultado_agrupamento_#{group}_dimensao_indicador_#{dimension}_#{indicator_id}")
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

