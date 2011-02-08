module UniFreire
  module Graphics
    class GeralDimensao
      def self.create_report_data(institution_id)

        connection = ActiveRecord::Base.connection

        institution = connection.execute("select group_id, region_id from institutions where id = 72").fetch_row
        group_id, region_id = institution[0], institution[1]
        connection.execute "
          delete from report_data where institution_id = #{institution_id}
          "
          
# Calculo da media da UE
        connection.execute "
          insert into report_data select institution_id,'média da UE',1,segment_name,avg(score) as media,dimension,indicator,question
          from comparable_answers where institution_id= #{institution_id} and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question;
          "
# Calculo da media da Ed. Infantil
        connection.execute "insert into report_data
          select #{institution_id},'média da Ed. Infantil',2,segment_name,avg(score) as media,dimension,indicator,question  from comparable_answers
          where year=2010  and segment_name <> 'Alessandra'  and level_name = 2
          group by segment_name,dimension,indicator,question;"

# Calculo da media do Ensino Fundamental
        connection.execute "
          insert into report_data
          select #{institution_id},'média do Ensino Fundamental',3,segment_name,avg(score) as media,dimension,indicator,question  from comparable_answers
           where year=2010  and segment_name <> 'Alessandra' and level_name in (3,4)
          group by segment_name,dimension,indicator,question;"

# Calculo da media do agrupamento

        connection.execute "insert into report_data
          select #{institution_id},'média do agrupamento',4,segment_name,avg(score) as media,dimension,indicator,question
          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
          where i.group_id=#{group_id} and ca.year=2010  and ca.segment_name <> 'Alessandra'
          group by ca.segment_name,ca.dimension,ca.indicator,ca.question;"

# Calculo da media da regiao
        connection.execute "insert into report_data
          select #{institution_id},'média da região',5,segment_name,avg(score) as media,dimension,indicator,question
          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
          where i.region_id=#{region_id} and ca.year=2010  and ca.segment_name <> 'Alessandra'
          group by ca.segment_name,ca.dimension,ca.indicator,ca.question;"

      end
      
      def self.create(institution_id, dimension_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT segment_name, 
                 sum_type, 
                 AVG(score) AS media 
          FROM   report_data 
          WHERE  institution_id = #{institution_id}
                 AND dimension = #{dimension_id}
          GROUP  BY segment_name, 
                    item_order 
        "

        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :colors => UniFreire::Graphics::Generator::COLORS[:five])
        colors={"média da UE"=>0,"média da Ed. Infantil"=>1,
        "média do Ensino Fundamental"=>2, "média do agrupamento"=>3,
        "média da região" =>4 ,"color"=>Generator::COLORS[:five]}
        graphic.generate(result,colors)
      end
      
    end
  end
end
