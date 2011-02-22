module UniFreire
  module Graphics
    class MapGenerator
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"

      def self.generate(institution_id)
        connection = ActiveRecord::Base.connection
        result = connection.execute "
          select institution_id,segment_name,number,score
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          group by institution_id, segment_order,dimension,indicator,question;
          "
        numbers_result = connection.execute "
          select distinct number
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
          order by dimension,indicator,question
        "
        institutions_result = connection.execute "
          select distinct institution_id
          from comparable_answers ca
          inner join institutions i on i.id=ca.institution_id
          where year=2010 and i.infantil_type in (1,2,3)
        "
        data = UniFreire::Graphics::DataParser.as_hash(result)
        numbers = UniFreire::Graphics::DataParser.as_array(numbers_result)
        institutions = UniFreire::Graphics::DataParser.as_array(institutions_result)
        build_html(data, numbers, institutions)
        html_file = File.new(File.join(TEMP_DIRECTORY,'mapa.html'))
        eps_files = convert_to_eps(html_file)
        eps_files
      end

private


#  [[institution_id, {"Gestores"=>{"1.1.1"=>score}}]]
      def self.parser(data)
        array_temp  = Array.new(2)
        array_temp[1] = []
        hash_segment_temp = {}
        hash_number_temp = {}
        institution_id = nil
        segment_name = nil
        number = nil
        data.each do |d|
          institution_id ||= d[0]
          if institution_id == d[0]
            array_temp[0] = institution_id
            segment_name ||= d[1]
            array_temp[1] << create_new_hash_segment_temp(number, d, hash_number_temp, hash_segment_temp, segment_name)
          else
            return array_temp
            array_temp[0] = d[0]
            array_temp[1] = []
            segment_name = d[1]
            array_temp[1] << create_new_hash_segment_temp(number, d, hash_number_temp, hash_segment_temp, segment_name)
          end
        end
      end

      def self.create_new_hash_segment_temp(number, d, hash_number_temp, hash_segment_temp, segment_name)
        if number == d[2]
          hash_number_temp[number] = d[3]
          hash_segment_temp[segment_name] = hash_number_temp
        else
          number = d[2]
          hash_number_temp[number] = d[3]
          hash_segment_temp[segment_name] = hash_number_temp
        end
        hash_segment_temp
      end

      def self.create_new_segment(segment_name, d, number, hash_segment_temp, hash_number_temp)
        if segment_name == d[1]
          number ||= d[2]
          hash_segment_temp = create_new_hash_segment_temp(number, d, hash_number_temp, hash_segment_temp)
        else
          segment_name = d[1]
          number = d[2]
          hash_segment_temp = create_new_hash_segment_temp(number, d, hash_number_temp, hash_segment_temp)
        end
      end

      def self.build_html(data, numbers, institutions)
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
               text-align:center;
               font-size: 8px;
               }
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
            .break_page {}
            @media print {
              .break_page { page-break-after: always;}
            }
          </style>

          </head>
          <body>
HEREDOC

        # primeira linha com as dimensões e indicadores
        first_table = '<table>'
        second_table = '<table>'
        first_header = ''
        second_header = ''
        first_table << "<tr> <td colspan = \"2\"> </td>"
        second_table << "<tr> <td colspan = \"2\"> </td>"
        first_header << "<tr> <td colspan = \"2\"> </td>"
        second_header << "<tr> <td colspan = \"2\"> </td>"
        numbers.size.times do |n|
          if n > 89
            second_table << "<td class=\"vertical_text\"> #{numbers[n]} </td>"
            second_header << "<td class=\"vertical_text\"> #{numbers[n]} </td>"
          else
            first_table << "<td class=\"vertical_text\"> #{numbers[n]} </td>"
            first_header << "<td class=\"vertical_text\"> #{numbers[n]} </td>"
          end
        end
        first_table << "</tr>"
        second_table << "</tr>"
        first_header << "</tr>"
        second_header << "</tr>"
        @funcs = %w(Gestores Professores Funcionários Familiares)
        break_page_count = 0
        @break = false
        institutions.each do |i|
          break_page_count += 1
          indicator = I18n.t("institutions.i#{i.first}")
          first_table << "<tr> <td rowspan = \"#{(@funcs.count+1)}\"> #{indicator} </td>"
          second_table << "<tr> <td rowspan = \"#{(@funcs.count+1)}\"> #{indicator} </td>"
          @funcs.each do |f|
            first_table << "<tr> <td> #{f} </td>"
            second_table << "<tr> <td> #{f} </td>"
            numbers.size.times do |n|
              number = numbers[n].first
              number_filled = false
              if n > 89
                data["9"].each do |d|
                  begin
                    if !d[f][number].nil?
                      second_table << "<td> #{d[f][number]} </td>"
                      number_filled = true
                      break
                    end
                  rescue
                    next
                  end
                end
                second_table << "<td> - </td>" if number_filled == false
              else
                data["9"].each do |d|
                  begin
                    if !d[f][number].nil?
                      first_table << "<td> #{d[f][number]} </td>"
                      number_filled = true
                      break
                    end
                  rescue
                    next
                  end
                end
                first_table << "<td> - </td>" if number_filled == false
              end
            end
            second_table << "</tr>"
            first_table << "</tr>"
          end
          first_table << "</tr>"
          second_table << "</tr>"
        end
        if break_page_count == 40
          first_table << "</table> <div class=\"break_page\"> </div>"
          second_table << "</table> <div class=\"break_page\"> </div>"
          html_code << first_table
          html_code << second_table
          break_page_count = 0
          first_table = "<table> #{first_header}"
          second_table = "<table> #{second_header}"
        end
        first_table << "</table>"
        second_table << "</table>"
        html_code << first_table
        html_code << second_table
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


      def self.convert_to_eps(html_file)
        pdf_file = convert_html_to_pdf(html_file)
        eps_file = File.join(TEMP_DIRECTORY,'quadro')
        (1..2).each do |i|
        `pdftops -eps -f #{i} -l #{i} #{pdf_file} #{eps_file}_#{i}.eps 1> /dev/null 2> /dev/null`
        end
        #`rm #{pdf_file}`
        get_eps_files_generated
      end

      def self.convert_html_to_pdf(html_file)
        kit = PDFKit.new(html_file)
        kit.to_pdf
        pdf_file = File.join(TEMP_DIRECTORY,'mapa.pdf')
        kit.to_file(pdf_file)
        pdf_file
      end

      def self.get_eps_files_generated
        files = []
        eps_file_pattern = File.join(TEMP_DIRECTORY,"mapa*.eps")
        Dir.glob(eps_file_pattern).each {|file_name| files << file_name}
        files.sort!
      end

    end #MapGenerator
  end #Graphics
end #UniFreire

