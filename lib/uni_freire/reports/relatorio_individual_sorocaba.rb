module UniFreire
  module Reports
    SIZE = {:default => '700x540', :wide => '1500x600'}
    class RelatorioIndividualSoracaba
      require "fileutils"
      TEMPLATE_DIRECTORY=File.expand_path( File.join(RAILS_ROOT,"lib/uni_freire/reports/relatorio_individual_sorocaba/template"))
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"
      PUBLIC_DIRECTORY = File.expand_path "#{RAILS_ROOT}/public"
      COLORS = {
          :three => %w(#004586 #ff420e #ffd320),
          :five  => %w(#579d1c #004586 #ff420e #83caff #74132c)
        }

      def initialize(institution_id)
        @institution_id = institution_id
        connection = ActiveRecord::Base.connection
        @institution_name = connection.execute("
          SELECT name FROM institutions
          WHERE id = #{@institution_id}"
          ).fetch_row[0].gsub(/[^a-z0-9çâãáàêẽéèîĩíìõôóòũûúù' ']+/i, '')
        @file_name = @institution_name.remover_acentos.gsub(' ', '_')
      end

      def report
        doc = RGhost::Document.new
        doc.define_tags do
          tag :font1, :name => 'HelveticaBold', :size => 12, :color => '#000000'
          tag :index, :name => 'Helvetica', :size => 8, :color => '#000000'
        end
        
        doc.image File.expand_path("capa_0002.eps", TEMPLATE_DIRECTORY)
        doc.next_page

        # salta 7 páginas
        8.times do |i|
          doc.image next_page_file(doc)
          # adiciona nome da escola em cima do sumário
          if i == 0
            doc.moveto :x => 10.5, :y => 26.4
            doc.show "#{@institution_name}", :with => :font1, :align => :show_center
          end
          doc.next_page
        end

        legend=[]
        legend=[{:name => "2008",:color => COLORS[:three][0]},
                {:name => "2009",:color => COLORS[:three][1]},
                {:name => "2010",:color => COLORS[:three][2]}]

        # 1.2. Gráfico geral da série histórica dos resultados das dimensões
        doc.image next_page_file(doc)
        file = UniFreire::Graphics::ResultadosDimensoes.create(@institution_id, UniFreire::Reports::SIZE[:wide],legend)
        doc.image file, :x => 1.6, :y => 9.5, :zoom => 32
        doc.showpage
        doc.image next_page_file(doc)

        # 1.3. Gráficos da série histórica dos resultados dos indicadores
        files = UniFreire::Graphics::ResultadosIndicadores.create(@institution_id, UniFreire::Reports::SIZE[:default],legend)
        show_graphics(files, doc)
        
        doc.showpage
        doc.image next_page_file(doc)
        doc.showpage
        doc.image next_page_file(doc)

        legend=UniFreire::Graphics::GeralDimensao.create_report_data(@institution_id,COLORS[:five])
        # 2. Análise dos resultados por dimensões e indicadores
        y = [0, 15, 15.5, 16.5, 15.5, 15.5, 15.5, 14.5, 15.5, 15.5, 16.5, 15.5]
        (1..11).each do |dimension_id|
          file = UniFreire::Graphics::GeralDimensao.create(@institution_id, dimension_id, UniFreire::Reports::SIZE[:wide], legend)
          doc.image file, :x => 1.6, :y => y[dimension_id], :zoom => 32
          doc.showpage
          doc.image next_page_file(doc)

          files = UniFreire::Graphics::Indicadores.create(@institution_id, dimension_id, UniFreire::Reports::SIZE[:default], legend)
          show_graphics(files, doc)

          if dimension_id != 11
            doc.showpage
            doc.image next_page_file(doc)
          end
        end
        
        %w(anexo1 expediente).each do |special_page|
          doc.next_page
          doc.image File.expand_path("#{special_page}.eps", TEMPLATE_DIRECTORY)
          doc.show "#{@index}", :with => :index, :align => :page_right if special_page == "anexo1"
        end
        
        doc.render :pdf, :debug => true, :quality => :prepress,
          :filename => File.join(PUBLIC_DIRECTORY,"relatorio_#{@file_name}_#{@institution_id}.pdf"),
          :logfile => File.join(TEMP_DIRECTORY,"sorocaba.log")

        Dir["#{TEMP_DIRECTORY}/#{@institution_id}*"].each { |file| FileUtils.rm(file)}

        ActiveRecord::Base.connection.execute("delete from report_data where institution_id=#{@institution_id}")
        true
      end

    private

      def show_graphics(files, doc)
        x = 1
        y = 20.3
        graphics_in_line = 0
        graphics_in_page = 0

        files.each do |file|
          if (x % 2) == 0
            doc.image file, :x => 10.5, :y => y, :zoom => 32
          elsif x == 11
            doc.image file, :x => 1.6, :y => y, :zoom => 32
          else
            doc.image file, :x => 2, :y => y, :zoom => 32
          end
          y -= 7 if (x % 2) == 0
          x += 1
          graphics_in_line +=1
          graphics_in_page +=1

          if files.count > 6 && (x == 7) || (x == 13)
            doc.showpage
            add_index(doc)
            y = 20.3
          end

        end
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
        File.join(TEMPLATE_DIRECTORY,"pg_%04d.eps" % pg_no)
      end
      
      def add_index(doc)
        @index ||= 2
        doc.show "#{@index}", :with => :index, :align => :page_right
        @index += 1
      end

    end
  end
end

