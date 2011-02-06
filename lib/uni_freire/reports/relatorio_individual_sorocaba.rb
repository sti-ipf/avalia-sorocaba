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
        file = UniFreire::Graphics::ResultadosDimensoes.create(@connection, 72, '960x400')
        doc.image file, :x => 1.6, :y => 9.5, :zoom => 50
        doc.showpage
        doc.image next_page_file
        doc.render :pdf, :filename => File.expand_path("~/Desktop/reports/report_#{@institution_id}.pdf"), :debug => true, :quality => :prepress,
                    :logfile => "/tmp/sorocaba.log"
                    return        
        graphics_hash = UniFreire::Graphics::ResultadosIndicadores.new(@institution_id,"450x215").graphics
        
        top = 22.3
        axis_x = [2,10.5] * graphics_hash.size
        graphics_hash.keys.sort.each_with_index do |key,i|
          g = graphics_hash[key]
          file = g.save_temporary
           #page break
          if (i % 10) == 0 && i != 0
            top = 27.3
            doc.next_page
          end

          #next graphic row
          if (i % 2) == 0 && i != 0
            top-=5
          end
          doc.image file, :x => axis_x.shift, :y => top, :zoom => 50
        end
        doc.showpage
        doc.image next_page_file
        doc.showpage
        doc.image next_page_file
        
        #Dimensoes
        (1..11).each do |dim|
          g = UniFreire::Graphics::GeralDimensao.new(@institution_id, dim,"650x265")
          # p g
          g.marker_font_size = 14
          file = g.save_temporary
          y = dim == 1 ? 13.5 : 15.5
          doc.image file, :x => 2.5, :y => y, :zoom => 65
          doc.showpage
          doc.image next_page_file
          
          
          graphics_hash = UniFreire::Graphics::GraficosIndicadores.new(@institution_id,dim,"450x215").graphics
          top = 19.3
          axis_x = [2,10.5] * graphics_hash.size
          graphics_hash.keys.sort.each_with_index do |key,i|
              g = graphics_hash[key]
              file = g.save_temporary
              next if file.nil?
               #page break
              if ( i % 8) == 0 && i != 0
                top = 27.3
                doc.next_page
              end

              #next graphic row
              if (i % 2) == 0 && i != 0
                top-=5
              end
              doc.image file, :x => axis_x.shift, :y => top, :zoom => 50

          end
          
          if dim != 11
            doc.showpage
            doc.image next_page_file
          end
        end
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
    end
  end
end
