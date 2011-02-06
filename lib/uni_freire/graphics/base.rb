module UniFreire 
  module Graphics
    class Base < Gruff::Bar

      TMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"      
      COLORS = {
        :three => %w(#004586 #ff420e #ffd320),
        :five  => %w(#579d1c #83caff #74132c #004586 #ff420e)
        }
      SIZE = {:wide => "960X400"}
      DEFAULT_PARAMS = {
        :minimum_value    => 0,
        :maximum_value    => 5,
        :margins          => 5,
        :top_margin       => 0,
        :legend_font_size => 14,
        :marker_font_size => 14,  
        :legend_box_size  => 14,
        :title_font_size  => 18,
        :bar_spacing      => 1
        }

      def initialize(params={})
        params = {:title => '',:size => SIZE[:wide], :colors => COLORS[:three]}.merge(params)
        super(params[:size])
        self.title = params[:title] if !params[:title].nil?
        self.theme = {
          :colors => params[:colors],
          :marker_color => '#004586', #orange
          :font_color => 'black',
          :background_colors => 'white'
        }
        DEFAULT_PARAMS.each {|k, v| self.instance_variable_set("@#{k}", v)}
      end
      
      def save(optional_name=nil)
        target_file = target_file(optional_name || "_graphic_#{self.object_id}")
        self.write target_file
        target_file
      end
            
    private
      def target_file(chart_name)
        filename = chart_name << '.jpg'
        File.join(TMP_DIRECTORY,filename)
      end
  
    end
  end
end
