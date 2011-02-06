module UniFreire
  module Graphics
    class Generator
      def initialize(institution, size, type)
        @type = type
        @size = size
        @graphics = {}
        @institution_id = (institution.is_a?(Numeric)) ? institution : institution.id
        @graphic =  UniFreire::Graphics::Base.new(@size)
        @colors = @graphic.theme_options[:colors]
        @connection = ActiveRecord::Base.connection
      end
      
      def generate
        case @type
          when "general of results for the dimensions series"
            result = @connection.execute "
              SELECT dimensao, ano, SUM(nota) / COUNT(*) AS media
              FROM   all_answers 
              WHERE  id_instituicao = 72 
              GROUP  BY ano, dimensao; 
            "
            @datasets = []
            result.each do |r|
              @ano ||= r[1]
              @medias ||= []
              if @ano == r[1]
                @medias << ((r[2].nil?)? 0 : r[2].to_f.round)
              else
                @datasets << [@ano,@medias]
                @ano, @medias = nil, []
                @medias << ((r[2].nil?)? 0 : r[2].to_f.round)
              end
            end
            @datasets << [@ano,@medias]
            color_index = 0
            @datasets.each do |data| 
              puts "_" * 100
              puts data.inspect
              @graphic.data(data[0], data[1], @colors[color_index])
              color_index += 1
            end
            (1..11).each{|i| @graphic.labels[i-1] = "#{i}"}
            @graphic.bar_spacing = 0.4
          when "historic series of results indicators"
        end
        @graphic
      end
    end
  end
end
