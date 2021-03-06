module UniFreire
  module Graphics
    class GeralDimensao

      AVG_UE="média da UE"
      AVG_INFANTIL="média da Ed. Infantil"
      AVG_FUNDAMENTAL="média do Ensino Fund. e Médio"
      AVG_REGIAO="média da região"
      AVG_AGRUPAMENTO="média do agrupamento"

      def self.check_if_is_infantil_fundamental(institution_id)
        infantil,fundamental=false,false
        service_levels = ActiveRecord::Base.connection.execute("select service_level_id from institutions_service_levels where institution_id = #{institution_id}")
        service_levels.each do |sl|
          sl_id = sl[0].to_i
          if sl_id == 2
            infantil=true
          elsif sl_id ==3 || sl_id ==4
            fundamental=true
          end
        end
        return infantil,fundamental
      end


      def self.create_report_data(institution_id,colors)

        legend=[]
        connection = ActiveRecord::Base.connection
        institution = connection.execute("select group_id, region_id, primary_service_level_id from institutions where id = #{institution_id}").fetch_row
        group_id, region_id, primary_service_level_id = institution[0], institution[1], institution[2]
        group_id=0 if group_id.nil?
        region_id=0 if region_id.nil?

        infantil,fundamental=check_if_is_infantil_fundamental(institution_id)

        connection.execute "DELETE FROM report_data WHERE institution_id = #{institution_id}"

        # Calculo da media da UE
        connection.execute "
          insert into report_data select institution_id,'#{AVG_UE}',1,segment_name,segment_order,avg(score) as media,dimension,indicator,question
          from comparable_answers where score>0 and institution_id= #{institution_id} and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question;
          "
          legend << {:name=>AVG_UE,:color=>colors[0]}

        # Calculo da media da Ed. Infantil
        if infantil
          connection.execute "insert into report_data
            select #{institution_id},'#{AVG_INFANTIL}',2,segment_name,segment_order,avg(score) as media,dimension,indicator,question  from comparable_answers
            where year=2010  and segment_name <> 'Alessandra'  and level_name = 2 and score>0
            group by segment_name,dimension,indicator,question;"
          legend << {:name=>AVG_INFANTIL,:color=>colors[1]}
        end

        # Calculo da media do Ensino Fundamental
        if fundamental
          connection.execute "
            insert into report_data
            select #{institution_id},'#{AVG_FUNDAMENTAL}',3,segment_name,segment_order,avg(score) as media,dimension,indicator,question  from comparable_answers
             where year=2010  and segment_name <> 'Alessandra' and score>0 and level_name in (3,4)
            group by segment_name,dimension,indicator,question;"
          legend << {:name=>AVG_FUNDAMENTAL,:color=>colors[2]}
        end

        # Calculo da media do agrupamento
        connection.execute "insert into report_data
          select #{institution_id},'#{AVG_AGRUPAMENTO}',4,segment_name,segment_order,avg(score) as media,dimension,indicator,question
          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
          where i.group_id=#{group_id} and ca.year=2010  and ca.score>0 and ca.segment_name <> 'Alessandra'
          group by ca.segment_name,ca.dimension,ca.indicator,ca.question;"
        legend << {:name=>AVG_AGRUPAMENTO,:color=>colors[3]}

        in_clause=[]
        if infantil
          in_clause << 2
        end
        if fundamental
          in_clause << 3
          in_clause << 4
        end
        in_clause = in_clause.join(",")
        # Calculo da media da regiao
#        connection.execute "insert into report_data
#          select #{institution_id},'#{AVG_REGIAO}',5,segment_name,segment_order,avg(score) as media,dimension,indicator,question
#          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
#          where i.region_id=#{region_id}
#          and i.primary_service_level_id  in (#{in_clause})
#          and ca.year=2010  and ca.segment_name <> 'Alessandra'
#          group by ca.segment_name,ca.dimension,ca.indicator,ca.question;"
#        legend << {:name=>AVG_REGIAO,:color=>colors[4]}

        connection.execute("delete from report_data where segment_order=2") if !infantil
        connection.execute("delete from report_data where segment_order=3") if !fundamental

        legend
      end

      def self.create(institution_id, dimension_id, size, legend, title=nil)

        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT segment_name,sum_type,AVG(media) as new_media from
          (SELECT segment_name,
                 item_order,
                 segment_order,
                 sum_type, indicator,
                 AVG(score) AS media
          FROM   report_data
          WHERE  institution_id = #{institution_id}
                 AND dimension = #{dimension_id}
                 AND score > 0
          GROUP  BY segment_order, item_order,indicator) a
          GROUP BY segment_order, item_order
        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :marker_font_size => 12,
                                :no_data_message=> "\n Não há dados \npara esta \n dimensão")
        graphic.generate(result,legend,"#{institution_id}_geral_dimensao_#{dimension_id}")
      end

    end
  end
end

