module UniFreire
  module Graphics
    class Indicadores

      def self.create(institution_id, dimension_id, size, legend, title=nil)
        connection = ActiveRecord::Base.connection
        indicators_result = connection.execute("select indicator from comparable_answers
          where dimension=#{dimension_id} and institution_id=#{institution_id} group by indicator;")
        indicators = []
        indicators_result.each {|i| indicators << i[0]}
        graphics = []

        indicators.each do |indicator_id|
          result = connection.execute "
            select segment_name,sum_type,avg(score) as media from report_data
            where indicator = #{indicator_id}  AND score > 0 and institution_id=#{institution_id} and dimension=#{dimension_id}
    				group by segment_order, sum_type, item_order
            "
          graphic = UniFreire::Graphics::Generator.new(:size => size, :title => "Indicador #{dimension_id}.#{indicator_id}")
          graphics << graphic.generate(result,legend,
                   "#{institution_id}_dimensao_indicador_#{dimension_id}_#{indicator_id}")
        end
        graphics
      end

    end
  end
end

