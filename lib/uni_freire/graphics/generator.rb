module UniFreire
  module Graphics
    class Generator < Gruff::Bar

      TMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"      
      COLORS = {
          :three => %w(#004586 #ff420e #ffd320),
          :five  => %w(#579d1c #83caff #74132c #004586 #ff420e)
        }
      DEFAULT_PARAMS = {
        :minimum_value    => 0,
        :maximum_value    => 5,
        :margins          => 5,
        :top_margin       => 0,
        :legend_font_size => 20,
        :marker_font_size => 18,  
        :legend_box_size  => 14,
        :title_font_size  => 24,
        :bar_spacing      => 1
        }
      SERIE, LEGEND, DATA = 0, 1, 2

      def initialize(params={})
        params = {:title => nil, :colors => COLORS[:three]}.merge(params)
        super(params[:size])
        self.title = params[:title] if !params[:title].nil?
        self.theme = {
          :colors => params[:colors],
          :marker_color => 'black',
          :font_color => 'black',
          :background_colors => 'white'
        }
        DEFAULT_PARAMS.each {|k, v| self.instance_variable_set("@#{k}", v)}
      end
        
      #estrutura os dados para gerar o gráfico e salva no diretório temporário  
      def generate(result, file_name=nil)
        build_graphic_with_data(result)
        save(file_name)
      end
            
    private
    
      def build_graphic_with_data(db_result)
        result,legends = result_as_hash(db_result)
        datasets = []
        series = []
        data = {}
        series_data = {}
        actual_serie = nil
        legends.each {|l| data[l] = []}
        
        result.each do |r|
          ser=r[1]
          legends.each do |leg|
            ser[leg] = "0" if ser[leg].nil?
            data[leg] << ser[leg].to_f
          end
        end
        legends.each do |leg|
          datasets << [leg,data[leg]]
        end
        
        # adiciona nova sequência de dados vazia, para dá o espaçamento entre as séries
        datasets << [" ", Array.new(result.size,0), "white"]
        
        #adiciona os datasets no gráfico
        datasets.each do |ds| 
          # ds[0] = legenda | ds[1] = dados | 
          # ds[2] = cor da barra - definida apenas quando é o dataset de espaçamento
          # quando não definida irá seguir o theme do gráfico
          self.data(ds[0], ds[1], ds[2])
        end
        #adiciona os labels do gráfico de acordo com as series
        label_index = 0
        
        result.each do |r|
          self.labels[label_index] = "#{r[0]}"
          label_index += 1
        end      
        
      end
      
      def result_as_hash(db_result)
        arr = []
        legends = []
        arr_serie = nil
        cur_serie = nil
        db_result.each do |r|
          cur_serie ||= r[SERIE]
          if cur_serie == r[SERIE]
            arr_serie ||= [r[SERIE],{}]
            arr_serie[1][r[LEGEND]]=r[DATA]
          else
            arr << arr_serie
            arr_serie=[r[SERIE],{}] 
            arr_serie[1][r[LEGEND]]=r[DATA]
            cur_serie=r[SERIE]
          end
          legends << r[LEGEND] if !legends.include?(r[LEGEND])
        end
        arr << arr_serie
        return arr,legends
      end
      
   
      def target_file(chart_name)
        filename = chart_name << '.jpg'
        File.join(TMP_DIRECTORY,filename)
      end
      
      #salva o gráfico baseado num nome ou o id do objeto
      def save(optional_name=nil)
        target_file = target_file(optional_name || "_graphic_#{self.object_id}")
        self.write target_file
        target_file
      end
      
    end
  end
end
