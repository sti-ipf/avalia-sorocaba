module UniFreire
  module Graphics
    class Generator < Gruff::Bar

      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"
      DEFAULT_PARAMS = {
        :minimum_value    => 0,
        :maximum_value    => 5,
        :margins          => 5,
        :top_margin       => 0,
        :legend_font_size => 18,
        :marker_font_size => 16,
        :legend_box_size  => 14,
        :title_font_size  => 22,
        :bar_spacing      => 1,
        #:marker_count     => 6,
        :legend_margin => 30,
        :sort             => false
        }

      def initialize(params={})
        params = {:title => nil}.merge(params)
        super(params[:size])
        self.title = params[:title] if !params[:title].nil?
        self.marker_color = "black"
        self.font_color = "black"
        self.theme = {
          :marker_color => 'black',
          :font_color => 'black',
          :background_colors => 'white'
        }
        DEFAULT_PARAMS.each {|k, v| self.instance_variable_set("@#{k}", v)}
      end

      #estrutura os dados para gerar o gráfico e salva no diretório temporário
      def generate(db_result,legends)
        file_name=nil
        build_graphic_with_data(db_result,legends)
        save(file_name)
      end

    private

      def build_graphic_with_data(db_result,legends)
        graph_data = DataParser.new(db_result,legends)
        series = graph_data.series
        datasets = graph_data.normalized_data

        # adiciona nova sequência de dados vazia, para dá o espaçamento entre as séries
        datasets << [" ", Array.new(series.count,0), "white"]

        #adiciona os datasets no gráfico
        datasets.each do |ds|
          # ds[0] = legenda | ds[1] = dados |
          # ds[2] = cor da barra - definida apenas quando é o dataset de espaçamento
          # quando não definida irá seguir o theme do gráfico
          self.data(ds[0], ds[1], ds[2])
        end

        #adiciona os labels do gráfico de acordo com as séries
        label_index = 0
        series.each do |serie|
          self.labels[label_index] = "#{serie}"
          label_index += 1
        end
      end

      def target_file(chart_name)
        filename = chart_name << '.jpg'
        File.join(TEMP_DIRECTORY,filename)
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

