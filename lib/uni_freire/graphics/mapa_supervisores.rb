module UniFreire
  module Graphics
    class MapaSupervisores

      def self.create(supervisor_id)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          SELECT i.id,new_segment_name,concat(dimension,'.',indicator) as number,
          ROUND(AVG(score),1) AS media
          FROM comparable_answers ca
          INNER JOIN institutions i ON i.id = ca.institution_id
          WHERE i.supervisor_id = #{supervisor_id} AND year = '2010' AND segment_name <> 'Alessandra'
          AND score > 0
          GROUP BY i.id, new_segment_order,dimension, indicator, year;
          "
        numbers_result = connection.execute "
          select distinct concat(dimension,'.',indicator) as number
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.supervisor_id = #{supervisor_id}
          order by dimension,indicator
          "
        connection.execute "select @a:=0"
        institutions_result = connection.execute "
          select if(@a, @a:=@a+1, @a:=1) as row_num , IF((0+i.alias)=0,i.alias,CONCAT('zz',i.name)) as z,
          i.id
          from institutions i where i.supervisor_id = #{supervisor_id}
          order by z
          "
        numbers = UniFreire::Graphics::DataParser.as_array(numbers_result,true)
        numbers = UniFreire::Graphics::DataParser.numbers_with_media(numbers)
        institutions = UniFreire::Graphics::DataParser.as_array(institutions_result)
        data = UniFreire::Graphics::DataParser.map_with_dimension_media(result, institutions, numbers)
        UniFreire::Graphics::MapGenerator.generate(:data => data, :numbers => numbers,
          :institutions => institutions, :columns_size => 89, :with_colors => false,
          :header_height => "40px",
          :file_name => "mapa_supervisor_#{supervisor_id}")
      end
    end
  end
end

