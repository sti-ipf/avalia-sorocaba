module UniFreire
  module Graphics
    class GraficosIndicadores
      attr_reader :graphics
      def initialize(institution,dimension, size="600x300")
        @size = size
        @graphics = {}
        to_id = lambda{|model| (model.is_a?(Numeric)) ? model : model.id }
        @institution_id = to_id.call(institution)
        @dimension_id   = to_id.call(dimension)
        make
      end

      def make
         # result = Answer.find_by_sql([%Q{select  indicator,service_levels,year, avg(answer_value(zero,one,two,three,four,five)) as avg
         #  from (
         #   -- gets only a question per user,question and survey_id
         #   select  indicator_id(questions.number) as indicator,levels.name as service_levels, year(answers.created_at) as year, answers.user_id,answers.survey_id,answers.question_id,zero,one,two,three,four,five
         #     from answers,surveys, users, segments,segments_service_levels as seg_levels, questions, institutions as inst, institutions_service_levels as islevels, service_levels as levels
         #
         #     where
         #    answers.survey_id= surveys.id and
         #    surveys.segment_id = segments.id and
         #    questions.survey_id = surveys.id and
         #    answers.question_id = questions.id and
         #
         #    inst.id = islevels.institution_id and
         #    levels.id = islevels.service_level_id and
         #
         #    seg_levels.service_level_id = levels.id and
         #    seg_levels.segment_id = segments.id and
         #    users.institution_id = inst.id and
         #    answers.user_id = users.id and
         #    inst.id  = ? and
         #    dimension_id(questions.number) = ?
         #  group by 1,2,3,4,5,6
         #  order by 1 asc
         #  ) as result group by 1,2 order by 1
         #   }, @institution_id, @dimension_id])
         result = Answer.find_by_sql([%Q{
           select distinct
              indicator_id(a.numero) as indicator,
               a.level_name as service_levels,
               year(a.data) as year,
               avg(case when a.nota = 6 then 0 else a.nota end) as avg
           from all_answers a
           where
             a.id_instituicao  = ? and
             dimension_id(a.numero) = ?
           group by
            indicator_id(a.numero),
            a.level_name,
            year(a.data)}, @institution_id, @dimension_id])
         group = result.group_by{|r| r['indicator'].to_i}

          group_all = {}
          group.each do |indicator, values|
            group_all[indicator] = values.group_by{|row|  row['service_levels'] }
          end

          group_all.each do |indicator, hash_values|
            graphic = UniFreire::Graphics::Base.new(@size)

            # colors = %w(#FFD33F #FF361E #004584)
            colors = graphic.theme_greyscale[:colors]

            hash_values.each do |service_levels, values|
               _labels, _data = {}, []
                label_idx = 0
               values.each do |row|
                 _labels[  label_idx] = row['indicator'] #.split(/\./).last.to_i
                 label_idx+=1
                 _data << row['avg'].to_f
               end
              graphic.labels = _labels
              graphic.title = "Indicador #{values.first['indicator'] }"
              graphic.data service_levels.to_s,_data, colors.shift
            end

            @graphics[indicator] = graphic

        end
      end
    end
  end
end