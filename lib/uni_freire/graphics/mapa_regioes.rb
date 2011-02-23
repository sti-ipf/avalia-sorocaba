module UniFreire
  module Graphics
    class MapaRegioes

      def self.create(region_id)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT i.alias,segment_name,concat(dimension,'.',indicator) as number, AVG(score) AS media
          FROM comparable_answers ca
          INNER JOIN institutions i ON i.id = ca.institution_id
          WHERE i.region_id = #{region_id}
          GROUP BY i.alias, segment_name,dimension, indicator, year;
          "
        numbers_result = connection.execute "
          select distinct concat(dimension,'.',indicator) as number
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.region_id = #{region_id}
          order by dimension,indicator
          "
        institutions_result = connection.execute "
          select distinct i.alias, IF((0+i.alias)=0,i.alias,CONCAT('zz',i.alias)) as z
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.region_id = #{region_id}
          order by z
          "
        numbers = UniFreire::Graphics::DataParser.as_array(numbers_result)
        numbers = UniFreire::Graphics::DataParser.numbers_with_media(numbers)
        institutions = UniFreire::Graphics::DataParser.as_array(institutions_result)
        data = UniFreire::Graphics::DataParser.map_with_dimension_media(result, numbers)
        data
#        UniFreire::Graphics::MapGenerator.generate(data, numbers, institutions, 89)
      end
    end
  end
end

