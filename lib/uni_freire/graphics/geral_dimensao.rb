module UniFreire
  module Graphics
    class GeralDimensao

      LEGENDS = ["média da UE","média da Ed. Infantil",
        "média do Ensino Fundamental", "média do agrupamento", "média da região"]
          
      def self.create_report_data(institution_id)
        connection = ActiveRecord::Base.connection
        institution = connection.execute("SELECT group_id, region_id FROM institutions WHERE id = 72").fetch_row
        group_id, region_id = institution[0], institution[1]
        connection.execute "DELETE FROM report_data WHERE  institution_id = #{institution_id}"
          
        # Cálculo da média da UE
        connection.execute "
          INSERT INTO report_data 
          SELECT institution_id, '#{LEGENDS[0]}', 1, segment_name, AVG(score) AS media, 
                 dimension, indicator, question 
          FROM   comparable_answers 
          WHERE  institution_id = #{institution_id} AND YEAR = 2010
                 AND segment_name <> 'Alessandra' 
          GROUP  BY segment_name, dimension, indicator, question; 
          "
        # Cálculo da média da Ed. Infantil
        connection.execute "
          INSERT INTO report_data 
          SELECT #{institution_id}, '#{LEGENDS[1]}', 2, segment_name, 
                 AVG(score) AS media, dimension, indicator, question 
          FROM   comparable_answers 
          WHERE  YEAR = 2010 AND segment_name <> 'Alessandra' AND level_name = 2 
          GROUP  BY segment_name, dimension, indicator, question; 
          "
        # Cálculo da média do Ensino Fundamental
        connection.execute "
          INSERT INTO report_data 
          SELECT #{institution_id}, '#{LEGENDS[2]}', 3, segment_name, 
                 AVG(score) AS media, dimension, indicator, question 
          FROM   comparable_answers 
          WHERE  YEAR = 2010 AND segment_name <> 'Alessandra' 
                 AND level_name IN (3, 4) 
          GROUP  BY segment_name, dimension, indicator, question; 
          "
        # Cálculo da média do agrupamento
        connection.execute "
          INSERT INTO report_data 
          SELECT #{institution_id}, '#{LEGENDS[3]}', 4, segment_name, 
                 AVG(score) AS media, dimension, indicator, question 
          FROM   comparable_answers ca 
                 INNER JOIN institutions i ON i.id = ca.institution_id 
          WHERE  i.group_id = #{group_id} AND ca.YEAR = 2010 
                 AND ca.segment_name <> 'Alessandra' 
          GROUP  BY ca.segment_name, ca.dimension, ca.indicator, ca.question; 
          "
        # Cálculo da média da região
        connection.execute "
          INSERT INTO report_data 
          SELECT #{institution_id}, '#{LEGENDS[4]}', 5, segment_name, 
                 AVG(score) AS media, dimension, indicator, question 
          FROM   comparable_answers ca 
                 INNER JOIN institutions i ON i.id = ca.institution_id 
          WHERE  i.region_id = #{region_id} AND ca.YEAR = 2010 
                 AND ca.segment_name <> 'Alessandra' 
          GROUP  BY ca.segment_name, ca.dimension, ca.indicator, ca.question; 
          "
      end

      def self.create(institution_id, dimension_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT segment_name, sum_type, AVG(score) AS media
          FROM   report_data
          WHERE  institution_id = #{institution_id}
                 AND dimension = #{dimension_id}
          GROUP  BY segment_name, item_order
          "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title, :colors => UniFreire::Graphics::Generator::COLORS[:five])
        colors={"legend" => LEGENDS ,"color"=>Generator::COLORS[:five]}
        graphic.generate(result,colors)
      end

    end
  end
end
