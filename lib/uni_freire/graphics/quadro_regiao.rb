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
        educandos = false

        in_clause=[]
        if infantil
          in_clause << 2
        end
        if fundamental
          in_clause << 3
          in_clause << 4
          educandos = true
        end
        in_clause = in_clause.join(",")

        # Calculo da media da regiao
        connection.execute "insert into report_data
          select #{institution_id},'#{AVG_REGIAO}',5,segment_name,segment_order,avg(score) as media,dimension,indicator,question
          from comparable_answers ca inner join institutions i on i.id=ca.institution_id
          where i.region_id=#{region_id}
          and i.primary_service_level_id  in (#{in_clause})
          and ca.year=2010  and ca.segment_name <> 'Alessandra'
          group by ca.segment_name,ca.dimension,ca.indicator,ca.question;"

        connection.execute "update report_data set segment_name='Funcionários', segment_order=4 and institution_id = #{institution_id} where segment_name like 'Func%'"
        connection.execute "update report_data set segment_name='Professores', segment_order=2 and institution_id = #{institution_id} where segment_name like 'Prof%'"

        result = connection.execute "
          SELECT CONCAT(dimension,'.',indicator) AS i, segment_name,
            sum_type, AVG(score) AS media
          FROM report_data
          WHERE score > 0 AND institution_id= #{institution_id} AND sum_type IN ('média da UE', 'média da região')
          GROUP BY dimension, indicator, segment_order, sum_type DESC"
        data = UniFreire::Graphics::DataParser.as_array(result)
        data = parser(data)
        build_html(data, educandos)
        html_file = File.new(File.join(TEMP_DIRECTORY,'quadro.html'))
        eps_files = convert_to_eps(html_file)
        eps_files
      end

private

      def self.parser(data)
        array_final = []
        hash_temp = {}
        hash_segment_temp = {}
        di = nil
        segment_name = nil
        data.each do |d|
          di ||= d[0]
          if di == d[0]
            segment_name ||= d[1]
            if segment_name == d[1]
              hash_segment_temp[segment_name] ||= Array.new(2)
              if d[2] == 'média da UE'
                hash_segment_temp[segment_name][0] = d[3]
              else
                hash_segment_temp[segment_name][1] = d[3]
              end
            else
              hash_segment_temp[segment_name][0] = '-' if hash_segment_temp[segment_name][0].nil?
              hash_segment_temp[segment_name][1] = '-' if hash_segment_temp[segment_name][1].nil?
              hash_temp[di] = hash_segment_temp
              segment_name = d[1]
              hash_segment_temp[segment_name] = Array.new(2)
              if d[2] == 'média da UE'
                hash_segment_temp[segment_name][0] = d[3]
              else
                hash_segment_temp[segment_name][1] = d[3]
              end
            end
          else
            hash_segment_temp[segment_name][0] = '-' if hash_segment_temp[segment_name][0].nil?
            hash_segment_temp[segment_name][1] = '-' if hash_segment_temp[segment_name][1].nil?
            hash_temp[di] = hash_segment_temp
            array_final << hash_temp
            hash_temp = {}
            di = d[0]
            hash_segment_temp = {}
            segment_name = d[1]
            hash_segment_temp[segment_name] = Array.new(2)
            if d[2] == 'média da UE'
              hash_segment_temp[segment_name][0] = d[3]
            else
              hash_segment_temp[segment_name][1] = d[3]
            end
          end
        end
        hash_temp[di] = hash_segment_temp
        array_final << hash_temp
      end

      def self.build_html(data, educandos)
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
            .break_page {}
            h5{font-size:12px;}
            h4{font-size:12px;}
            li{font-size:11px; width:87%; text-align: justify;}
            .note{margin-top: 15px;font-size:11px; width:87%; text-align: justify;}
            @media print {
              .break_page { page-break-after: always;}
            }
          </style>

          </head>
          <body>
          <h4>3. ANÁLISE DOS RESULTADOS PELA REGIÃO</h4>
          <h5>3.1. Questões problematizadoras para reflexão</h5>
          <ul>
          <li>
            A partir dos resultados das regiões geográficas do município, o que podemos observar?
            Existe alguma correlação entre os resultados obtidos e as escolas localizadas em
            determinada região? Que elementos podem ter contribuído para este resultado?
          </li>
          </ul>
            <table width='100%'>
              <tr>
                <td "#{INDICATOR_HEADER_COLOR}"> </td>
HEREDOC
        header << "<tr> <td #{INDICATOR_HEADER_COLOR}>  </td>"
        if educandos
          @header1 = %w(Gestores Professores Funcionários Familiares Educandos)
      else
          @header1 = %w(Gestores Professores Funcionários Familiares)
        end
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
        @indicadores = []
        data.each {|d| @indicadores << d.keys.first}
        @indicadores
        @indicadores.each do |i|
          html_code << "</table> <div class=\"break_page\"> </div> <table width=100%>#{header}" if i == "7.1"
          html_code << "<tr> <td #{INDICATOR_HEADER_COLOR}> #{i} </td>"
          @data = get_info_from_indicator(data, i, @header1)
          i=0
          styles=[UE_COLOR,REGION_COLOR]
          @data.each do |d|
            html_code << "<td #{styles[i % 2]}> #{d} </td>"
            i+=1
          end
        end
        html_code << '</tr>'

        html_code << <<HEREDOC
            </table>
            <div class="note">
            <b>Observação:</b> A coluna da região refere-se ao cálculo da média das unidades educacionais que estão na mesma
            região com o mesmo nível (Educação Infantil e Ensino Fundamental e Médio) . As escolas cujas médias da região
            aparece em branco referem-se aos casos em que não há outras unidades com o seu perfil.
            </div>
          </body>
          </html>
HEREDOC

        html_file = File.new(File.join(TEMP_DIRECTORY,'quadro.html'), 'w+')
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

      def self.get_segment_names(data)
        info = []
        data.each do |d|
          d.values.each do |v|
            v.keys.each do |k|
              info << k if !info.include?(k)
            end
          end
        end
        info
      end

      def self.get_info_from_indicator(data, indicator, header)
        info = []
        data.each do |d|
          if d.keys.first == indicator
            header.each do |h|
              if d[indicator][h].nil?
                2.times {info << '-'}
              else
                media_ue =  if d[indicator][h][0].size > 1
                              d[indicator][h][0].to_f.round(1)
                            else
                              d[indicator][h][0]
                            end
                media_regiao =  if d[indicator][h][1].size > 1
                              d[indicator][h][1].to_f.round(1)
                            else
                              d[indicator][h][1]
                            end
                info << media_ue
                info << media_regiao
              end
            end
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

