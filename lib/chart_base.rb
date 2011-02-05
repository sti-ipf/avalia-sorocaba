module UniFreire 
  module Charts
    class Base
      BASE_DIRECTORY = File.expand_path "#{RAILS_ROOT}/public/graficos"
      DEFAULT_PARAMS = {
        :size => "400x500",
        :colors => ['#3704ba','#bd0004','#f8e900'],
        :marker => 'black',
        :background_colors => 'white',
        :marker_count => 10,
        :maximum_value => 5,
        :minimum_value => 0,
        :sort => false,
        :name => "untitled"
      }.freeze
      attr_reader :chart
      #options param has the same of DEFAULT_PARAMS key names. Each key will be an instace variable.
      def initialize(options={})
        self_options = DEFAULT_PARAMS.dup.merge(options) 
       
        self_options.keys.each{|key| instance_variable_set "@#{key}",self_options[key] }
        puts self.inspect
        @chart = default_chart
      end
      
      #generates absolute file path based on chart_name.
      def target_file(chart_name)
        filename = chart_name.to_s << '.png'
        File.join(BASE_DIRECTORY,filename)
      end
      
      #saves @chart into disk, using optional_name or @name.  
      def save(optional_name=nil)
        @chart.write target_file(optional_name || @name)
      end
      
      private 
      def default_chart
        chart = Gruff::Bar.new #(@size)
        #chart.minimum_value =  @minimum_value
        #chart.maximum_value =  @maximum_value
        #chart.marker_count = @marker_count
        #chart.sort = @sort
  
        chart
      end          
    end
  end
end