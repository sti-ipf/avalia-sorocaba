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
          :five  => %w(#579d1c #83caff #74132c #004586 #ff420e)
        }

      def initialize(institution_id)
        @institution_id = institution_id
        connection = ActiveRecord::Base.connection
        @institution_name = connection.execute("
          SELECT name FROM institutions
          WHERE id = #{@institution_id}"
          ).fetch_row[0].remover_acentos.gsub(/[^a-z0-9]+/i, '')
      end

      def report
        doc = RGhost::Document.new
        %W(capa_0002 contra_capa).each do |special_page|
          doc.image File.expand_path("#{special_page}.eps", TEMPLATE_DIRECTORY)
          doc.next_page
        end

        # salta 5 páginas
        5.times do
          doc.image next_page_file
          doc.next_page
        end
        legend=[]
        legend=[{:name => "2008",:color => COLORS[:three][0]},
                {:name => "2009",:color => COLORS[:three][1]},
                {:name => "2010",:color => COLORS[:three][2]}]

        # 1.2. Gráfico geral da série histórica dos resultados das dimensões
        doc.image next_page_file
        file = UniFreire::Graphics::ResultadosDimensoes.create(@institution_id, UniFreire::Reports::SIZE[:wide],legend)
        doc.image file, :x => 1.6, :y => 9.5, :zoom => 32
        doc.showpage
        doc.image next_page_file

        # 1.3. Gráficos da série histórica dos resultados dos indicadores
        files = UniFreire::Graphics::ResultadosIndicadores.create(@institution_id, UniFreire::Reports::SIZE[:default],legend)

        show_graphics(files, doc)

        doc.showpage
        doc.image next_page_file
        doc.showpage
        doc.image next_page_file

        legend=UniFreire::Graphics::GeralDimensao.create_report_data(@institution_id,COLORS[:five])
        # 2. Análise dos resultados por dimensões e indicadores
        y = [0, 13.5, 16, 16, 15, 15, 15, 15, 15, 15, 16, 15]
        (1..11).each do |dimension_id|
          file = UniFreire::Graphics::GeralDimensao.create(@institution_id, dimension_id, UniFreire::Reports::SIZE[:wide], legend)
          doc.image file, :x => 1.6, :y => y[dimension_id], :zoom => 32
          doc.showpage
          doc.image next_page_file

          files = UniFreire::Graphics::Indicadores.create(@institution_id, dimension_id, UniFreire::Reports::SIZE[:default], legend)
          show_graphics(files, doc)

          if dimension_id != 11
            doc.showpage
            doc.image next_page_file
          end
        end

        doc.render :pdf, :debug => true, :quality => :prepress,
          :filename => File.join(PUBLIC_DIRECTORY,"relatorio_#{@institution_name}_#{@institution_id}.pdf"),
          :logfile => File.join(TEMP_DIRECTORY,"sorocaba.log")

        Dir["#{TEMP_DIRECTORY}/#{@institution_id}*"].each { |file| FileUtils.rm(file)}

        ActiveRecord::Base.connection.execute("delete from report_data where institution_id=#{@institution_id}")

        true
      end

      def inc_page
        @inc_page ||= 0
        @inc_page += 1
      end

      def next_page_file
        page_file(inc_page)
      end

      def page_file(pg_no)
        File.join(TEMPLATE_DIRECTORY,"pg_%04d.eps" % pg_no)
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
            y = 20.3
          end

        end
      end

    end
  end
end

