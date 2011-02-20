module UniFreire
  module Graphics
    class MapGenerator
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"

      def self.generate(institution_id)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          select CONCAT(dimension, '.',  indicator) as di,
          institution_id, segment_name,avg(score) as media
          from report_data
          where score > 0 AND segment_name not in ('Média Geral') and sum_type = 'média da UE'
          group by institution_id,  0+di, segment_order, item_order
          "
        data = UniFreire::Graphics::DataParser.as_array(result)
        build_html(data)
      end

private

      def self.build_html(data)
        header = ''
        html_code = <<HEREDOC
          <!DOCTYPE html>
          <html lang='pt-BR'>
          <head>
          <meta charset='utf-8'>

          <style type="text/css">
            table{border:1px solid black;
                  border-collapse: collapse;}
            tr{border:1px solid black;}
            td{border:1px solid black;
               width:15px;padding:2px;
               text-align:center;}
            .vertical_text{
              text-align: center;
              vertical-align: middle;
              width: 20px;
              margin: 0px;
              padding: 5px 1px;
              white-space: nowrap;
              -webkit-transform: rotate(-90deg);
              -moz-transform: rotate(-90deg);
              transform: rotate(-90deg);
            }
          </style>

          </head>
          <body>
            <table>
HEREDOC

        # primeira linha com as dimensões e indicadores
        @dimensions = get_info(data, 0)
        html_code << "<tr> <td colspan = \"2\"> </td>"
        @dimensions.each do |d|
          html_code << "<td class=\"vertical_text\"> #{d} </td>"
        end
        html_code << "</tr>"
        @escolas = get_info(data, 1, 1)
        @funcs = get_info(data, 2, 4)
        @escolas.each do |e|
          html_code << "<tr> <td rowspan = \"#{(@funcs.count+1)}\"> #{e} </td>"
            @funcs.each do |f|
              html_code << "<tr> <td> #{f} </td>"
              @dados = 1..10
              @dados.each do |d|
                html_code << "<td> #{d} </td>"
              end
              html_code << "</tr>"
            end
            html_code << "</tr>"
        end
        html_code << "</table> </body> </html>"
        html_file = File.new(File.join(TEMP_DIRECTORY,'mapa.html'), 'w+')
        html_file.puts html_code
        html_file.close
      end

      def self.get_info(data, position, stop_at=nil)
        info = []
        first_data = nil
        i = 0
        data.each do |d|
          info << d[position] if !info.include?(d[position])
          if !stop_at.nil?
            first_data ||= d[position]
            i += 1 if first_data == d[position]
            break if i == stop_at
          end
        end
        info
      end

    end #MapGenerator
  end #Graphics
end #UniFreire

