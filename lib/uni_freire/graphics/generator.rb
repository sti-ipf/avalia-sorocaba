module UniFreire
  module Graphics
    class Generator < Gruff::Bar

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
        
      def generate(result)
        build_graphic_with_data(result)
        self.save
      end
      
    private
    
      def build_graphic_with_data(db_result)
        datasets = []
        series = []
        legend = nil
        data = []
        
        #r[0] = série | r[1] = legenda | r[2] = dado
        db_result.each do |r| 
          #inclui nova série se ela não tiver sido adicionada
          series << r[0] if !series.include?(r[0]) 
          legend ||= r[1]

          #se a legenda igual a atual, armazena o dado, junto com os demais dados da legenda
          if legend == r[1]
            data << r[2].to_f.round
          else
            #datasets recebe todos os dados de uma legenda
            datasets << [legend,data]

            #dados são zerados, pois há uma nova legenda e uma sequencia nova de dados
            data = []
            legend = r[1]
            data << r[2].to_f.round
          end
        end
        
        datasets << [legend,data]
        # adiciona nova sequência de dados vazia, para dá o espaçamento entre as séries
        datasets << [" ", Array.new(series.size,0), "white"]
        
        #adiciona os datasets no gráfico
        datasets.each do |ds| 
          # ds[0] = legenda | ds[1] = dados | 
          # ds[2] = cor da barra - definida apenas quando é o dataset de espaçamento
          # quando não definida irá seguir o theme do gráfico
          self.data(ds[0], ds[1], ds[2])
        end

        #adiciona os labels do gráfico de acordo com as series
        label_indice = 0
        series.each do |serie|
          self.labels[label_indice] = "#{serie}"
          label_indice += 1
        end      
        
      end
      
      def save(optional_name=nil)
        target_file = target_file(optional_name || "_graphic_#{self.object_id}")
        self.write target_file
        target_file
      end
      
      def target_file(chart_name)
        filename = chart_name << '.jpg'
        File.join(TMP_DIRECTORY,filename)
      end
    end
  end
end
