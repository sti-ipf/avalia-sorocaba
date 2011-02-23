module UniFreire
  module Graphics
    class MapaInfantil

      def self.create
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          select i.alias,new_segment_name,number,score
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          group by i.alias, new_segment_order, dimension, indicator, question;
          "
        numbers_result = connection.execute "
          select distinct number
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          order by dimension,indicator,question
        "
        institutions_result = connection.execute "
          select distinct i.alias
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          order by alias
        "
        data = UniFreire::Graphics::DataParser.as_hash(result)
        numbers = UniFreire::Graphics::DataParser.as_array(numbers_result)
        institutions = UniFreire::Graphics::DataParser.as_array(institutions_result)
        UniFreire::Graphics::MapGenerator.generate(data, numbers, institutions, 89)
      end
    end
  end
end

