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
          data << r.first
        end
        data
      end

      def self.as_hash(result)
        data = {}
        school = nil
        segment_name = nil
        indicator = nil
        result.each do |r|
          data[r[0]] = {} if school != r[0]
          school = r[0]
          data[r[0]][r[1]] = {} if segment_name != r[1]
          segment_name = r[1]
          data[r[0]][r[1]][r[2]] = r[3]
        end
        data
      end

      def self.numbers_with_media(numbers)
        dimension = nil
        new_numbers = []
        new_number_control = true
        numbers.each do |n|
          actual_dimension = n.split('.')[0]
          dimension ||= actual_dimension
          new_numbers = add_new_number(new_numbers, dimension) if new_number_control
          new_number_control = false
          if actual_dimension == dimension
            new_numbers << n
          else
            dimension = actual_dimension
            new_numbers = add_new_number(new_numbers, dimension)
            new_numbers << n
          end
        end
        new_numbers
      end

      def self.map_with_dimension_media(result, institutions, numbers)
        data = as_hash(result)
        funcs = %w(Gestores Professores Funcionários Familiares)
        hash_temp = {}
        actual_dimension = nil
        institutions.each do |i|
          funcs.each do |f|
            numbers.each do |n|
              if n.include?("Dimen")
                actual_dimension = n
                hash_temp[actual_dimension] = []
                next
              end
              begin
                value = data[i][f][n].to_f.round(1)
                hash_temp[actual_dimension] << value if value != 0
              rescue
                next
              end
            end #numbers each
            hash_temp.each do |k,v|
              begin
                data[i][f][k] = calc_dimension_media(v)
              rescue
                next
              end
            end
            hash_temp = {}
          end #funcs each
        end #institutions each
        data
      end

    private

      def self.add_new_number(numbers, dimension)
        numbers << "Dimensão #{dimension}"
      end

      def self.calc_dimension_media(v)
        return nil if v.count == 0
        media = 0
        v.each {|d| media+=d}
        media = (media.to_f/v.count).to_f.round(1)
        media = (media.to_i == media)? media.to_i : media
      end

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

