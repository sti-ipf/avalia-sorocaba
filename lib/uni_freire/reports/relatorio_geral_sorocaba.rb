module UniFreire
  module Reports
    class RelatorioGeralSorocaba
      require "fileutils"
      TEMPLATE_DIRECTORY=File.expand_path( File.join(RAILS_ROOT,"lib/uni_freire/reports/relatorio_individual_sorocaba/template_geral"))
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"
      PUBLIC_DIRECTORY = File.expand_path "#{RAILS_ROOT}/public"

      INFANTIL_FUNDAMENTAL_INTEGRAL = 62
      INFANTIL_FUNDAMENTAL_PARCIAL = 63
      FUNDAMENTAL_PARCIAL = 64
      FUNDAMENTAL_INTEGRAL = 65
      FUNDAMENTAL_MEDIO = 66

      REPORT_TYPES = {
        :infantil=> {:number=>2,
                     :invalid_dimensions=>"7",
                     :invalid_indicators=> [ [], [7,8], [1,2,3,5,6], [], [] ,[] ,[] ,[4,5] ,[] ,[] ,[] ]
                     },
        :fundamental=> {:number=>3,
                        :invalid_dimensions=>"9",
                        :invalid_indicators=> [ [], [], [], [], [] ,[] ,[] ,[] ,[] ,[] ,[] ]
                        },
      }



      COLORS = {
          :three => %w(#004586 #ff420e #ffd320),
          :five  => %w(#579d1c #004586 #ff420e #83caff #74132c)
        }

      def initialize
      end

      def report
       doc = RGhost::Document.new
        doc.define_tags do
          tag :font1, :name => 'HelveticaBold', :size => 12, :color => '#000000'
          tag :index, :name => 'Helvetica', :size => 8, :color => '#000000'
        end

        doc.image File.expand_path("capa_geral.eps", TEMPLATE_DIRECTORY)
        doc.next_page

        # salta 8 páginas
        8.times do |i|
          doc.image next_page_file(doc)
          doc.next_page
        end


        legend=[]
        legend=[{:name => "2008",:color => COLORS[:three][0]},
                {:name => "2009",:color => COLORS[:three][1]},
                {:name => "2010",:color => COLORS[:three][2]}]

        # 1.2. Gráfico geral da série histórica dos resultados das dimensões - INFANTIL
        print_historico_geral(doc,REPORT_TYPES[:infantil],legend,9.5,20.8)
        graph_positions_infantil=[18.5,6,18.5,5.5,18.5,5,0,19.2,5,19.2,8]
        print_historico_indicadores(doc,REPORT_TYPES[:infantil],graph_positions_infantil,legend)

        print_historico_geral(doc,REPORT_TYPES[:fundamental],legend,15.5,24.7)
        graph_positions_fundamental=[18.5,6,18.5,5.5,18.5,5,18.4,6.1,0,19.2,8]
        print_historico_indicadores(doc,REPORT_TYPES[:fundamental],graph_positions_fundamental,legend)

        legend = UniFreire::Graphics::GeralResultadoInfantilFundamental.create_data(REPORT_TYPES)
        print_geral_resultado_infantil_fundamental(doc,legend)

        print_percentual_respondido(doc)

        #legend = UniFreire::Graphics::GeralResultadoInfantil.create_data(REPORT_TYPES)
        #print_geral_resultado_infantil(doc,legend)

        #doc.image next_page_file(doc)
        #doc.next_page
        #doc.image next_page_file(doc)
        #doc.next_page
        #doc.image next_page_file(doc)
        #doc.next_page

        #print_agrupamento (doc,INFANTIL_FUNDAMENTAL_INTEGRAL,true)
        #print_agrupamento (doc,INFANTIL_FUNDAMENTAL_PARCIAL,true)
        #print_agrupamento (doc,FUNDAMENTAL_PARCIAL,false)
        #print_agrupamento (doc,FUNDAMENTAL_INTEGRAL,false)
        #print_agrupamento (doc,FUNDAMENTAL_MEDIO,false)

        doc.render :pdf, :debug => true, :quality => :prepress,
          :filename => File.join(PUBLIC_DIRECTORY,"relatorio_geral.pdf"),
          :logfile => File.join(TEMP_DIRECTORY,"sorocaba.log")

#        html_file = File.new("/home/fabricio/ruby/sandbox/mapa/public/index.html")
#        kit = PDFKit.new(html_file)
#        kit.to_pdf
#        kit.to_file('/tmp/teste.pdf')

#        pdf = Magick::ImageList.new("/tmp/teste.pdf")
#        thumb = pdf
#        thumb.write File.join(TEMP_DIRECTORY,"teste.png")
      end

    private

      def print_historico_indicadores(doc,hash_report,graph_positions,legend)
        graph_count = 0
        11.times do |i|
          puts "Fazendo historico da dimensao #{i}"
          if i+1 != hash_report[:invalid_dimensions].to_i
            doc.image next_page_file(doc) if graph_count == 0
            file = UniFreire::Graphics::HistoricoGeralIndicador.create(i+1, UniFreire::Reports::SIZE[:wide],legend,hash_report)
            doc.image file, :x => 2, :y => graph_positions[i], :zoom => 32
            graph_count += 1
            if graph_count > 1
              doc.next_page
              graph_count = 0
            end
          end
        end
      end

      def print_historico_geral(doc,hash_report,legend,graph_pos,data_pos)
        doc.image next_page_file(doc)
        file = UniFreire::Graphics::HistoricoGeralDimensao.create(UniFreire::Reports::SIZE[:wide],legend,hash_report)
        doc.image file, :x => 1.6, :y => graph_pos, :zoom => 32

        doc.moveto :x => 8.4, :y => data_pos
        doc.show get_institutions_for_year("2008",hash_report[:number]), :with => :font1, :align => :show_center
        doc.moveto :x => 12.6, :y => data_pos
        doc.show get_institutions_for_year("2010",hash_report[:number]), :with => :font1, :align => :show_center
        doc.moveto :x => 16.9, :y => data_pos
        doc.show get_institutions_for_year("2010",hash_report[:number]), :with => :font1, :align => :show_center

        doc.next_page
      end

      def print_percentual_respondido(doc)
        doc.image next_page_file(doc)
        arr_results = []
        arr_results << UniFreire::Graphics::GeralPercentualRespondido.get_infantil
        arr_results << UniFreire::Graphics::GeralPercentualRespondido.get_data_for_type(INFANTIL_FUNDAMENTAL_INTEGRAL,84)
        arr_results << UniFreire::Graphics::GeralPercentualRespondido.get_data_for_type(INFANTIL_FUNDAMENTAL_PARCIAL,42)
        arr_results << UniFreire::Graphics::GeralPercentualRespondido.get_data_for_type(FUNDAMENTAL_PARCIAL,36)
        arr_results << UniFreire::Graphics::GeralPercentualRespondido.get_data_for_type(FUNDAMENTAL_INTEGRAL,60)
        arr_results << UniFreire::Graphics::GeralPercentualRespondido.get_data_for_type(FUNDAMENTAL_MEDIO,32)
        pos=[20.25,18.95,17.4, 16.45, 15.2, 13.6,12.65]
        i=0
        total=0
        arr_results.each do |a|
          doc.moveto :x => 17, :y => pos[i]
          doc.show a[:percentual], :with => :font1, :align => :show_center
          total += a[:count]
          i+=1
        end
        doc.moveto :x => 17, :y => pos[i]
        total_perc = ((total.fdiv 624) * 100).round(2).to_s << "%"
        doc.show total_perc, :with => :font1, :align => :show_center
        doc.next_page
      end


      def print_geral_resultado_infantil_fundamental(doc,legend)
        11.times do |t|
          dimension = t + 1
            graph_position=19.5
            graph_position=17 if dimension==1
            graph_position=19 if ((dimension==7) || (dimension==9))

            doc.image next_page_file(doc)

            file = UniFreire::Graphics::GeralResultadoInfantilFundamental.create_dimension(dimension,UniFreire::Reports::SIZE[:wide],legend)
            doc.image file, :x => 1.6, :y => graph_position, :zoom => 32

            files = UniFreire::Graphics::GeralResultadoInfantilFundamental.create_indicators(dimension,UniFreire::Reports::SIZE[:default],legend)
            show_graphics(files, doc,dimension)
        end
      end

      def print_quadro_respostas

      end

      def print_geral_resultado_infantil(doc,legend)
        11.times do |t|
          dimension = t + 1
          if dimension != 7
            graph_position=19
            graph_position=17.8 if dimension==1
            graph_position=19 if ((dimension==7) || (dimension==9))

            doc.image next_page_file(doc)

            file = UniFreire::Graphics::GeralResultadoInfantil.create_dimension(dimension,UniFreire::Reports::SIZE[:wide],legend)
            doc.image file, :x => 1.6, :y => graph_position, :zoom => 32

            files = UniFreire::Graphics::GeralResultadoInfantil.create_indicators(dimension,UniFreire::Reports::SIZE[:default],legend)
            show_graphics(files, doc,dimension)
          end

        end
      end

      def print_agrupamento (doc,group_id,show_dimension_nine)
        legend = UniFreire::Graphics::GeralResultadoAgrupamentos.create_data(group_id,REPORT_TYPES)
        print_geral_resultado_agrupamentos(doc,legend,group_id,show_dimension_nine)
        doc.image next_page_file(doc)
        doc.next_page
        doc.image next_page_file(doc)
        doc.next_page

      end

      def print_geral_resultado_agrupamentos(doc,legend,group_id,show_dimension_nine)
        11.times do |t|
          dimension = t + 1
          if (dimension!=9 || show_dimension_nine)
            graph_position=19
            graph_position=17.6 if dimension==1
            graph_position=18.3 if ((dimension==7) || (dimension==9))

            doc.image next_page_file(doc)

            file = UniFreire::Graphics::GeralResultadoAgrupamentos.create_dimension(group_id, dimension,UniFreire::Reports::SIZE[:wide],legend)
            doc.image file, :x => 1.6, :y => graph_position, :zoom => 32

            files = UniFreire::Graphics::GeralResultadoAgrupamentos.create_indicators(group_id, dimension,UniFreire::Reports::SIZE[:default],legend)
            show_graphics(files, doc,dimension)
          end
        end
      end



      def get_institutions_for_year(year ,institution_type)
          connection = ActiveRecord::Base.connection
          connection.execute("
          SELECT count(*) FROM institutions_year_history where year = #{year} and level_type=#{institution_type}"
          ).fetch_row[0]
      end

      def show_graphics(files, doc,dimension)
        x = 1
        first_page=true
        graphics_in_line = 0
        graphics_in_page = 0

        y=8.5
        y=10.5 if dimension > 1

        files.each do |file|
          if files.count > 4 && (((x == 5) && first_page) || (x == 7) || (x == 13))
            doc.next_page
            doc.image next_page_file(doc)
            y = 20.3
          end
          if x > 4 && first_page
            x = 1
            first_page=false
          end
          if (x % 2) == 0
            doc.image file, :x => 10.5, :y => y, :zoom => 32
          else
            doc.image file, :x => 2, :y => y, :zoom => 32
          end
          y -= 7 if (x % 2) == 0
          x += 1
          graphics_in_line +=1
          graphics_in_page +=1
        end
        doc.next_page
      end

      def inc_page
        @inc_page ||= 0
        @inc_page += 1
      end

      def next_page_file(doc)
        page_file(inc_page, doc)
      end

      def page_file(pg_no, doc)
        add_index(doc)
        File.join(TEMPLATE_DIRECTORY,"pg_#{pg_no}.eps")
      end

      def add_index(doc)
        @index ||= 2
        doc.show "#{@index}", :with => :index, :align => :page_right
        @index += 1
      end


    end
  end
end

