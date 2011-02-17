module UniFreire
  module Reports
    class RelatorioGeralSorocaba
      require "fileutils"
      TEMPLATE_DIRECTORY=File.expand_path( File.join(RAILS_ROOT,"lib/uni_freire/reports/relatorio_individual_sorocaba/template_geral"))
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"
      PUBLIC_DIRECTORY = File.expand_path "#{RAILS_ROOT}/public"
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
        
        # 1.2. Gráfico geral da série histórica dos resultados das dimensões
        doc.image next_page_file(doc)
        file = UniFreire::Graphics::ResultadosDimensoes.create(72, UniFreire::Reports::SIZE[:wide],legend)
        doc.image file, :x => 1.6, :y => 9.5, :zoom => 32
        
        doc.moveto :x => 8.4, :y => 20.8
        doc.show "X", :with => :font1, :align => :show_center
        doc.moveto :x => 12.6, :y => 20.8
        doc.show "X", :with => :font1, :align => :show_center
        doc.moveto :x => 16.9, :y => 20.8
        doc.show "X", :with => :font1, :align => :show_center
        
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
