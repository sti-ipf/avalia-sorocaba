module UniFreire
  module Reports
    class RelatorioIndividualSoracaba
      TEMPLATE_DIRECTORY=File.expand_path( File.join(RAILS_ROOT,"lib/uni_freire/reports/relatorio_individual_sorocaba/template"))
      def initialize(institution)
         to_id = lambda{|model| (model.is_a?(Numeric)) ? model : model.id }
        @institution_id = to_id.call(institution)
      end

      def report

        doc = RGhost::Document.new
        %W(capa_0002 contra_capa).each do |special_page|
          doc.image File.expand_path("#{special_page}.eps", TEMPLATE_DIRECTORY)
          doc.next_page
        end

        #salta 5 Paginas
        5.times do
          doc.image next_page_file
          doc.next_page
        end

        # Serie Historica
        doc.image next_page_file
        file = UniFreire::Graphics::ResultadosDimensoes.create(72, '960x400')
        doc.image file, :x => 1.6, :y => 9.5, :zoom => 46
        doc.showpage
        doc.image next_page_file
                
        
        files = UniFreire::Graphics::ResultadosIndicadores.create(72, 11,"500x400")
        
        show_graphics(files, doc)
        
        doc.showpage
        doc.image next_page_file
        doc.showpage
        doc.image next_page_file
        
        UniFreire::Graphics::GeralDimensao.create_report_data(72)
        #Dimensoes
        (1..11).each do |dimension_id|
          y = 13
          file = UniFreire::Graphics::GeralDimensao.create(72, dimension_id,'960x400')

          doc.image file, :x => 2.5, :y => y, :zoom => 46
          doc.showpage
          doc.image next_page_file

###
          files = UniFreire::Graphics::Indicadores.create(72, dimension_id,"500x400")
          
          show_graphics(files, doc)
          doc.showpage
###
        end
        
        doc.render :pdf, :filename => File.expand_path("~/Desktop/reports/report_#{@institution_id}.pdf"), :debug => true, :quality => :prepress,
                  :logfile => "/tmp/sorocaba.log"
        return
        
        puts "Generating #{@inc_page} pages..."
        doc.render :pdf, :filename => File.expand_path("~/Desktop/reports/report_#{@institution_id}.pdf"), :debug => true, :quality => :prepress,
                    :logfile => "/tmp/sorocaba.log"
      end

      def inc_page
        @inc_page ||= 0
        @inc_page += 1
      end

      def next_page_file
        p "Page #{@inc_page}"
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
            doc.image file, :x => 10.5, :y => y, :zoom => 46
          elsif x == 11
            doc.image file, :x => 2, :y => y, :zoom => 46          
          else
            doc.image file, :x => 2, :y => y, :zoom => 46
          end
          y -= 7 if (x % 2) == 0          
          x += 1
          graphics_in_line +=1
          graphics_in_page +=1
          
          
          if (x % 7) == 0 
            doc.showpage
            x = 1
            y = 20.3
          end
          
        end

      end
      
    end
  end
end

