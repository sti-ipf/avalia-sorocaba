module UniFreire
  module Graphics
    class ResultadosIndicadores

      def self.create(institution_id, size, legend, title=nil)
        connection = ActiveRecord::Base.connection
        graphics = []

        (1..11).each do |dimension_id|
          result = connection.execute "
            SELECT CONCAT(dimension,'.',indicator) as i, year, AVG(score) AS media
            FROM   comparable_answers
            WHERE  institution_id = #{institution_id} AND dimension = #{dimension_id} AND score > 0
            GROUP  BY indicator, year;
            "
          graphic =
            if dimension_id == 11
              UniFreire::Graphics::Generator.new(:size => UniFreire::Reports::SIZE[:wide], :title => "Dimensão #{dimension_id}")
            else
              UniFreire::Graphics::Generator.new(:size => size, :title => "Dimensão #{dimension_id}")
            end
          graphics << graphic.generate(result,legend,
                  "#{institution_id}_resultados_indicadores_#{dimension_id}")
        end
        graphics
      end

    end
  end
end

