module UniFreire
  module Graphics
    class ResultadosIndicadores
      attr_reader :graphics
      def initialize(institution,size="300x200")
        @size = size
        @graphics = {}
        @institution_id = (institution.is_a?(Numeric)) ? institution : institution.id
        make
      end

      def make

        # result = Answer.find_by_sql( [%Q{select  number,year, avg(answer_value(zero,one,two,three,four,five)) as avg
        #      from (
        #        -- gets only a question per user,question and survey_id
        #        select  questions.number as number, year(answers.created_at) as year, answers.user_id,answers.survey_id,answers.question_id,zero,one,two,three,four,five
        #          from answers,surveys, users, segments,segments_service_levels as seg_levels, questions, institutions as inst, institutions_service_levels as islevels, service_levels as levels
        #
        #          where
        #         answers.survey_id= surveys.id and
        #         surveys.segment_id = segments.id and
        #         questions.survey_id = surveys.id and
        #         answers.question_id = questions.id and
        #
        #         inst.id = islevels.institution_id and
        #         levels.id = islevels.service_level_id and
        #
        #         seg_levels.service_level_id = levels.id and
        #         seg_levels.segment_id = segments.id and
        #         users.institution_id = inst.id and
        #         answers.user_id = users.id and
        #         inst.id  = ?
        #
        #       group by 1,2,3,4,5
        #       order by 1 asc
        #
        #      ) as result group by 1}, @institution_id])
        result = Answer.find_by_sql([%Q{
        select
          a.numero as number,
          year(a.data) as year,
          avg(case when a.nota = 6 then 0 else a.nota end) as avg
        from all_answers a
        where
            a.id_instituicao  = ?
        group by
          a.numero,
          year(a.data)}, @institution_id])
        group = result.group_by{|r| r['number'].to_i}

         group_all = {}
         group.each do |indicator, values|
           group_all[indicator] = values.group_by{|row|  row['year'].to_i }

         end

         group_all.each do |indicator, hash_values|
           graphic =  UniFreire::Graphics::Base.new(@size)
           labels, data = {}, []
           # colors = %w(#FFD33F #FF361E #004584)
           colors = graphic.theme_greyscale[:colors]
           label_idx = 0
           hash_values.each do |year, values|
             labels, data = {}, []
              values.each do |row|
                i = row['number'].gsub(/^\d+\./,'')
                labels[label_idx] = i
                label_idx+=1
                data << row['avg'].to_f
              end
              graphic.data year.to_s,data, colors.shift
              graphic.title="Dimensão #{values.first['number'].scan(/^\d+/)}"
           end

           graphic.labels = labels
           @graphics[indicator] = graphic
           #break if @graphics.size > 9
        end

      end
    end
  end
end