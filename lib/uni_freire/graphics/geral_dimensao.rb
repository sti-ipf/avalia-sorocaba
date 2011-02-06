module UniFreire
  module Graphics
    class GeralDimensao
      
      def self.create(institution_id, size, title=nil)
        connection = ActiveRecord::Base.connection
        result = connection.execute "

        "
        graphic = UniFreire::Graphics::Generator.new(:size => size, :title => title)
        graphic.generate(result)
      end
      
    end
  end
end
