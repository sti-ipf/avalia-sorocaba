module UniFreire
  module Graphics
    class MapGenerator
      TEMP_DIRECTORY = File.expand_path "#{RAILS_ROOT}/tmp"

      def self.generate(data, numbers, institutions, columns_size)
        build_html(data, numbers, institutions, columns_size)
        html_file = File.new(File.join(TEMP_DIRECTORY,'mapa.html'))
        eps_files = convert_to_eps(html_file)
        eps_files
      end

    private
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

      def self.build_html(data, numbers, institutions, columns_size)
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
            .white{background-color:white}
            .red{background-color:red}
            .orange{background-color:orange}
            .blue{background-color:blue}
            .yellow{background-color:yellow}
            .green{background-color:green}
            .vertical_text{
              text-align: center;
              vertical-align: middle;
              width: 20px;
              height: 35px;
              margin: 0px;
              padding: 5px 1px;
              white-space: nowrap;
              -webkit-transform: rotate(-90deg);
              -moz-transform: rotate(-90deg);
              transform: rotate(-90deg);
            }
            .space_betweet_tables{height:20px;}
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
        [first_table, second_table, first_header, second_header].each {|s| s << "<tr> <td colspan = \"2\"> </td>"}
        numbers.size.times do |n|
          if n > columns_size
            [second_table, second_header].each {|s| s << "<td class=\"vertical_text\"> #{numbers[n]} </td>"}
          else
            [first_table, first_header].each {|s| s << "<td class=\"vertical_text\"> #{numbers[n]} </td>"}
          end
        end
        [first_table, second_table, first_header, second_header].each {|s| s << "</tr>"}
        @funcs = %w(Gestores Professores Funcionários Familiares)
        break_page_count = 0
        @break = false
        institutions.each do |i|
          break_page_count += 1
          institution = i.first
          [first_table, second_table].each {|s| s << "<tr> <td rowspan = \"#{(@funcs.count+1)}\"> #{institution} </td>"}
          @funcs.each do |f|
            [first_table, second_table].each {|s| s << "<tr> <td> #{f} </td>"}
            numbers.size.times do |n|
              number = numbers[n].first
              if n > columns_size
                second_table = add_data_in_table(data, institution, f, number, second_table)
              else
                first_table = add_data_in_table(data, institution, f, number, first_table)
              end
            end
            [second_table, first_table].each {|s| s << "</tr>"}
          end
          [first_table, second_table].each {|s| s << "</tr>"}
          if break_page_count == 40
            [first_table, second_table].each {|s| s << "</table> <div class=\"break_page\"> </div>"}
            html_code << first_table
            html_code << second_table
            break_page_count = 0
            first_table = "<table> #{first_header}"
            second_table = "<table> #{second_header}"
          end
        end
        if break_page_count < 20 || institutions.count <= 40
          first_table << "</table> <div class=\"space_betweet_tables\"></div>"
        else
          first_table << "</table> <div class=\"break_page\"> </div>"
        end
        second_table << "</table>"
        html_code << first_table
        html_code << second_table
        html_file = File.new(File.join(TEMP_DIRECTORY,'mapa.html'), 'w+')
        html_file.puts html_code
        html_file.close
      end

      def self.add_data_in_table(data, institution, f, number, table)
        number_filled = false
        begin
          value = data[institution][f][number]
          if !value.nil?
            css_class = get_css_class(value)
            table << "<td class = \"#{css_class}\"> #{value} </td>"
            number_filled = true
            break
          end
        rescue
        end
        table << "<td> - </td>" if number_filled == false
        table
      end

      def self.get_css_class(value)
        case value
          when "1"
            "red"
          when "2"
            "orange"
          when "3"
            "blue"
          when "4"
            "yellow"
          when "5"
            "green"
          else
            "white"
          end
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
        eps_file = File.join(TEMP_DIRECTORY,'mapa')
        (1..10).each do |i|
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

