module UniFreire
  module Graphics
    class Indicadores

      def self.create(institution_id, dimension_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        indicators_result = connection.execute("select indicator from comparable_answers
          where dimension=#{dimension_id} and institution_id=#{institution_id} group by indicator;")
        indicators = []        
        indicators_result.each {|i| indicators << i[0]}
        graphics = []

        indicators.each do |indicator_id|
          result = connection.execute "
            select question,sum_type,avg(score) as media from report_data 
            where indicator = #{indicator_id} and institution_id=#{institution_id} and dimension=#{dimension_id} 
    				group by question, sum_type, item_order
            "
          graphic = UniFreire::Graphics::Generator.new(:size => size, :title => "Dimensão #{dimension_id}.#{indicator_id}", :colors => UniFreire::Graphics::Generator::COLORS[:five])
          colors={"média da UE"=>0,"média da Ed. Infantil"=>1,
        "média do Ensino Fundamental"=>2, "média do agrupamento"=>3,
        "média da região" =>4 ,"color"=>Generator::COLORS[:five]}
          graphics << graphic.generate(result,colors)
        end
        graphics
      end

    end
  end
end

