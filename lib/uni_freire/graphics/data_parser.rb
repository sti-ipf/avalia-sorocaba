module UniFreire
  module Graphics
    class DataParser

      SERIE, LEGEND, DATA = 0, 1, 2

      attr_accessor :series_data, :legends, :normalized_data
      def initialize(data,legends)
        @series_data = get_series_with_legends_and_data(data)
        @series_data = [] if @series_data.first.nil?
        @legends = legends
        @normalized_data = normalize_data
      end

      def normalize_data
        legend_data = {}
        datasets = []
        self.legends.each {|l| legend_data[l[:name]] = []}

        self.series_data.each do |data|
          serie = data[1] #legendas com os dados
          self.legends.each do |legend|
            serie[legend[:name]] = "0" if serie[legend[:name]].nil?
            legend_data[legend[:name]] << serie[legend[:name]].to_f
          end
        end
        self.legends.each do |legend|
          datasets << [legend[:name],legend_data[legend[:name]],legend[:color]]
        end

        datasets
      end

      def series
        series = []
        self.series_data.each{|sd| series << sd[0]}
        series
      end

      def self.as_array(result)
        data = []
        result.each do |r|
          data << r
        end
        data
      end

    private
      def get_series_with_legends_and_data(data)
        series = []
        legends = []
        temp_serie  = nil
        current_serie = nil

        data.each do |d|
          current_serie ||= d[SERIE]
          if current_serie == d[SERIE]
            # série com a legenda e dado ex.:
            # ["11", [["2008", "4.1111"], ["2009", "3.0833"], ["2010", "4.6839"]]]
            #   |        |         |
            #  série   legenda   dado
            temp_serie ||= [d[SERIE],{}]
            temp_serie[1][d[LEGEND]] = d[DATA]
          else
            series << temp_serie
            temp_serie = [d[SERIE],{}]
            temp_serie[1][d[LEGEND]] = d[DATA]
            current_serie = d[SERIE]
          end
        end
        series << temp_serie
        series
      end

      def get_legends
        legends = []
        self.series_data.each do |sd|
          sd[1].each do |d|
            legend = d[0]
            legends << legend if !legends.include?(legend)
          end
        end
        legends.sort
      end

    end
  end
end

