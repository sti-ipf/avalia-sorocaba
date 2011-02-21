module UniFreire
  module Graphics
    class QuadroRegiao
      AVG_REGIAO="média da região"
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"
      INDICATOR_HEADER_COLOR = " width='8%' bgcolor='8f7f63'"
      SEGMENT_HEADER_COLOR = " width='18%' bgcolor='8f7f63'"
      UE_HEADER_COLOR = " width='9%' bgcolor='c7bbA5'"
      UE_COLOR = " bgcolor='defa70'"
      REGION_HEADER_COLOR = " width='9%' bgcolor='c7bbA5'"
      REGION_COLOR = " bgcolor='ffcd73'"

      def self.generate(institution_id)
        connection = ActiveRecord::Base.connection
        infantil,fundamental=check_if_is_infantil_fundamental(institution_id)

        institution = connection.execute("select group_id, region_id, primary_service_level_id from institutions where id = #{institution_id}").fetch_row
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
          select #{institution_id},'#{AVG_REGIAO}',5,segment_name,segment_order,avg(score) as media,dimension,indicator,question
          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
          where i.region_id=#{region_id}
          and i.primary_service_level_id  in (#{in_clause})
          and ca.year=2010  and ca.segment_name <> 'Alessandra' and ca.score > 0
          group by ca.segment_order,ca.dimension,ca.indicator,ca.question;"

        connection.execute "update report_data set segment_name='Funcionários', segment_order=4 and institution_id = #{institution_id} where segment_name like 'Func%'"
        connection.execute "update report_data set segment_name='Professores', segment_order=2 and institution_id = #{institution_id} where segment_name like 'Prof%'"

        result = connection.execute "
          SELECT CONCAT(dimension,'.',indicator) AS i, segment_name,
            sum_type, AVG(score) AS media
          FROM report_data
          WHERE score > 0 AND institution_id= #{institution_id} AND sum_type IN ('média da UE', 'média da região')
          GROUP BY dimension,indicator,segment_order, sum_type"
        #data = UniFreire::Graphics::DataParser.as_array(result)
        build_html(result)
        html_file = File.new(File.join(TEMP_DIRECTORY,'quadro.html'))
        eps_files = convert_to_eps(html_file)
        eps_files
      end

private

      def self.build_html(result)
        header = ''
        html_code = <<HEREDOC
          <!DOCTYPE html>
          <html lang='pt-BR'>
          <head>
          <meta charset='utf-8'>

          <style type="text/css">
            table {border:1px solid black; border-collapse: collapse;}
            tr {border:1px solid black;}
            td {border:1px solid black; padding:2px; text-align:center;}
            table {}
            @media print {
              table { page-break-after: always;}
            }
          </style>

          </head>
          <body>
            <table width='100%'>
              <tr>
                <td "#{INDICATOR_HEADER_COLOR}"> </td>
HEREDOC
        header << "<tr> <td #{INDICATOR_HEADER_COLOR}>  </td>"
        #@header1 = get_info(data, 1, 3)
        @header1 = ["Gestores","Professores","Funcionários","Familiares"]
        @header1.each do |d|
          html_code << "<td colspan = 2 #{SEGMENT_HEADER_COLOR}> #{d} </td>"
          header << "<td colspan = 2 #{SEGMENT_HEADER_COLOR}> #{d} </td>"
        end
        html_code << "</tr> <tr> <td #{INDICATOR_HEADER_COLOR}> </td>"
        header << "</tr> <tr> <td #{INDICATOR_HEADER_COLOR}> </td>"

        @header2 = %w(UE Região)
        @header1.size.times do |i|
          html_code << <<HEREDOC
            <td #{UE_HEADER_COLOR}> #{@header2[0]} </td>
            <td #{REGION_HEADER_COLOR}> #{@header2[1]} </td>
HEREDOC

          header << <<HEREDOC
            <td #{UE_HEADER_COLOR}> #{@header2[0]} </td>
            <td #{REGION_HEADER_COLOR}> #{@header2[1]} </td>
HEREDOC

        end
        html_code << '</tr>'
        header << '</tr>'
        fix_order = ''

        current_type = -1
        current_segment = ""
        current_indicator = ""
        result.each do |r|
          i = r[0]
          segment_name = r[1]
          sum_type = r[2]
          score = r[3]
          segment = {}
          indicator= {}
          if current_indicator != i
            write_line_html(indicator) if !current_indicator.nil?
            current_indicator = i
            current_segment_name = segment_name
            indicator = {}
            segment = {}
            segment[sum_type.to_s] = score
          elsif current_segment_name != segment_name
            indicator[segment_name]=segment if !current_segment_name.nil?
            current_segment_name = segment_name
            segment = {}
            segment[sum_type.to_s] = score
          else
            segment[sum_type.to_s] = score
          end

        end
        html_code << <<HEREDOC
            </table>
          </body>
          </html>
HEREDOC

        html_file = File.new(File.join(TEMP_DIRECTORY,'quadro.html'), 'w+')
        html_file.puts html_code
        html_file.close
      end

      def write_line_html (i,indicator,header_text,header_collection)
        html_to_return = ""
        html_to_return << "</table><table width='100%'>#{header}" if i == "7.1"
        html_code << "<tr> <td #{INDICATOR_HEADER_COLOR}> #{i} </td>"
        header_collection.each do |h|
          ue_value = "-"; region_value = "-"
          if !indicator[h].nil?
            ue_value = indicator[h]["1"] if !indicator[h]["1"].nil?
            region_value = if !indicator[h]["5"].nil?
          end
          html_code << "<td #{UE_COLOR}> #{ue_value} </td>"
          html_code << "<td #{REGION_COLOR}> #{region_value} </td>"
        end
        html_code << "</tr>"
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

      def self.convert_to_eps(html_file)
        pdf_file = convert_html_to_pdf(html_file)
        eps_file = File.join(TEMP_DIRECTORY,'quadro')
        (1..2).each do |i|
        `pdftops -eps -f #{i} -l #{i} #{pdf_file} #{eps_file}_#{i}.eps 1> /dev/null 2> /dev/null`
        end
        `rm #{pdf_file}`
        get_eps_files_generated
      end

      def self.convert_html_to_pdf(html_file)
        kit = PDFKit.new(html_file)
        kit.to_pdf
        pdf_file = File.join(TEMP_DIRECTORY,'quadro.pdf')
        kit.to_file(pdf_file)
        pdf_file
      end

      def self.get_eps_files_generated
        files = []
        eps_file_pattern = File.join(TEMP_DIRECTORY,"quadro*.eps")
        Dir.glob(eps_file_pattern).each {|file_name| files << file_name}
        files.sort!
      end

    end
  end
end

