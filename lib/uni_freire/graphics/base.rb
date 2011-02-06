require 'gruff'
require 'tempfile'
module UniFreire 
  module Graphics
    class Base < Gruff::Bar
      attr_reader :theme_options
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
        self.theme = {
          :colors => %w(#CCCCCC #AAAAAA #777777 #444444 #222222), #grayscale
          :marker_color => '#CCCCCC', # gray
          :font_color => 'black',
          :background_colors => 'white'
        }
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
