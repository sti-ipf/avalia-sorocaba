module UniFreire
  module Graphics
    class ResultadosIndicadores

      def self.create(institution_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "

        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title)
        colors={"2008"=>0,"2009"=>1,"2010"=>2,"color"=>Generator::COLORS[:three]}
        graphic.generate(result,colors)
      end

    end
  end
end

