module UniFreire
  module Graphics
    class MapaGrupos

      def self.create(group_id)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          select i.alias,new_segment_name,number,score
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
      	  inner join groups g on i.group_id = g.id
          where year=2010 and i.group_id = #{group_id}
          group by alias, new_segment_order, dimension, indicator, question;
          "
        numbers_result = connection.execute "
          select distinct number
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.group_id = #{group_id}
          order by dimension,indicator,question
          "
        institutions_result = connection.execute "
          select distinct i.alias
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.group_id = #{group_id}
          order by alias
          "
        data = UniFreire::Graphics::DataParser.as_hash(result)
        numbers = UniFreire::Graphics::DataParser.as_array(numbers_result)
        institutions = UniFreire::Graphics::DataParser.as_array(institutions_result)
        UniFreire::Graphics::MapGenerator.generate(:data => data, :numbers => numbers,
          :institutions => institutions, :columns_size => 89,
          :file_name => "mapa_grupo_#{group_id}")
      end
    end
  end
end

