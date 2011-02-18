module UniFreire
  module Graphics
    class TableGenerator
      AVG_REGIAO="média da região"
      def self.generate
        connection = ActiveRecord::Base.connection
        infantil,fundamental=check_if_is_infantil_fundamental(121)
        
        institution = connection.execute("select group_id, region_id, primary_service_level_id from institutions where id = 121").fetch_row
        group_id, region_id, primary_service_level_id = institution[0], institution[1], institution[2]
        
        in_clause=[]
        if infantil
          in_clause << 2
        end
        if fundamental
          in_clause << 3
          in_clause << 4
        end
        in_clause = in_clause.join(",")
        
        # Calculo da media da regiao
        connection.execute "insert into report_data
          select 121,'#{AVG_REGIAO}',5,segment_name,segment_order,avg(score) as media,dimension,indicator,question
          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
          where i.region_id=#{region_id}
          and i.primary_service_level_id  in (#{in_clause})
          and ca.year=2010  and ca.segment_name <> 'Alessandra'
          group by ca.segment_name,ca.dimension,ca.indicator,ca.question;"
          
        connection.execute "update report_data set segment_name='Funcionários', segment_order=4 and institution_id = 121 where segment_name like 'Func%'"
        connection.execute "update report_data set segment_name='Professores', segment_order=2 and institution_id = 121 where segment_name like 'Prof%'"
        
        result = connection.execute "
          SELECT CONCAT(dimension,'.',indicator) AS i, segment_name, 
            sum_type, AVG(score) AS media
          FROM report_data
          WHERE score > 0 AND institution_id= 121 AND sum_type IN ('média da UE', 'média da região')
          GROUP BY i, segment_name, sum_type
          ORDER BY 0+i, segment_order"
        data = parser_result(result)
        build_html(data)
      end
      
      def self.parser_result(result)
        data = []
        result.each do |r|
          data << r
        end
        data
      end
      
      def self.build_html(data)
        html_code = <<HEREDOC
          <!DOCTYPE html> 
          <html lang='pt-BR'> 
          <head> 
          <meta charset='utf-8'> 

          <style type="text/css">
            table {border:1px solid black; border-collapse: collapse;}
            tr {border:1px solid black;}
            td {border:1px solid black; width:15px;padding:2px; text-align:center;}
          </style>
          
          </head> 
          <body> 
            <table>
              <tr>
                <td> </td>
HEREDOC
        @header1 = get_info(data, 1, 3)
        @header1.each do |d|
          html_code << "<td colspan = 2> #{d} </td>"
        end
        html_code << '</tr> <tr> <td> </td>'
        
        @header2 = %w(UE Região)
        @header1.size.times do |i|
          html_code << <<HEREDOC
            <td> #{@header2[0]} </td>
            <td> #{@header2[1]} </td>
HEREDOC
        end
        html_code << '</tr>'
        
        @indicadores = get_info(data, 0)
        @indicadores.each do |i|
          html_code << "<tr> <td> #{i} </td>"
          @data = get_info_from_indicator(data, i)
          @data.each {|d| html_code << "<td> #{d} </td>"}
        end
        
        html_code << '</tr>'
        
        html_code << <<HEREDOC
            </table>
          </body> 
          </html>         
HEREDOC
        
        html_file = File.new('quadro.html', 'w+')
        html_file.puts html_code
        html_file.close
      end
      
      def self.check_if_is_infantil_fundamental(institution_id)
        infantil,fundamental=false,false
        service_levels = ActiveRecord::Base.connection.execute("select service_level_id from institutions_service_levels where institution_id = #{institution_id}")
        service_levels.each do |sl|
          sl_id = sl[0].to_i
          if sl_id == 2
            infantil=true
          elsif sl_id ==3 || sl_id ==4
            fundamental=true
          end
        end
        return infantil,fundamental
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
      
      def self.get_info_from_indicator(data, indicator)
        info = []
        data.each do |d|
          if d[0] == indicator
            info << d[3][0..2]
          end
        end
        10.times do |i|
          info[i] = "-" if info[i].nil?
        end
        info
      end
      
    end
  end
end
