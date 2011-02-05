require 'gruff'
require 'tempfile'
module UniFreire 
  module Graphics
    class Base < Gruff::Bar
      def initialize(size="600x215")
        super(size)
        self.minimum_value = 0
        self.maximum_value = 5
        self.legend_font_size = 14
        self.marker_font_size = 14  
        self.margins=5
        self.top_margin=0
        self.legend_box_size=14
        self.title_font_size = 18
        self.legend_font_size = 14
        self.marker_font_size = 18
        # self.theme = {
        #             :colors => %w(red #004584 yellow),
        #             :marker_color => 'gray',
        #             :background_colors => %w(white white) 
        #           }
        self.theme = theme_greyscale
      end
      
      def save_temporary
        #TODO change for ENV['TEMP']
        filename = "/tmp/_graphic_#{self.object_id}.jpg"
        File.open(filename, 'wb'){|f| f.puts to_blob('JPG') rescue nil } 
    
        filename
        
      end
  
    end
  end
end

require 'lib/uni_freire/graphics/historico_geral_dimensao.rb'
require 'lib/uni_freire/graphics/resultados_indicadores.rb'
require 'lib/uni_freire/graphics/geral_dimensao.rb'
require 'lib/uni_freire/graphics/graficos_indicadores.rb'