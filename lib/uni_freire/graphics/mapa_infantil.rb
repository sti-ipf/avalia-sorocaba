module UniFreire
  module Graphics
    class MapaInfantil

      def self.create
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          select i.id,new_segment_name,number,score
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3) and new_segment_name <> 'Alessandra'
          AND score > 0
          group by i.id, new_segment_order, dimension, indicator, question;
          "
        numbers_result = connection.execute "
          select distinct number
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          order by dimension,indicator,question
        "
        institutions_result = connection.execute "
          select distinct i.alias, i.name, i.id as id
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          order by alias
        "
        data = UniFreire::Graphics::DataParser.as_hash(result)
        numbers = UniFreire::Graphics::DataParser.as_array(numbers_result,true)
        institutions = UniFreire::Graphics::DataParser.as_array(institutions_result)
        UniFreire::Graphics::MapGenerator.generate(:data => data, :numbers => numbers,
          :institutions => institutions, :columns_size => 89, :file_name => "mapa_infantil", :has_students=>false)
      end
    end
  end
end

