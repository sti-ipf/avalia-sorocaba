module UniFreire
  module Graphics
    class HistoricoGeralDimensao < UniFreire::Graphics::Base
      def initialize(institution,size="600x300")
        super(size)
        @institution_id = (institution.is_a?(Numeric)) ? institution : institution.id
        make
      end

      def make
         # result = Answer.find_by_sql([%Q{select  dim,year, avg(answer_value(zero,one,two,three,four,five)) as avg
         # from (
         #   -- gets only a question per user,question and survey_id
         #   select  dimension_id(questions.number) as dim,year(answers.created_at) as year, answers.user_id,answers.survey_id,answers.question_id,zero,one,two,three,four,five
         #     from answers,surveys, users, segments,segments_service_levels as seg_levels, questions, institutions as inst, institutions_service_levels as islevels, service_levels as levels
         #
         #   where
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
         #    inst.id  = ?
         #  group by 1,2,3,4,5
         #  order by answers.id asc
         #
         # ) as result group by 1
         # }, @institution_id])
         result = Answer.find_by_sql([%Q{
           select
            dimension_id(a.numero) as dim,
            year(a.data) as year,
            avg(case when a.nota = 6 then 0 else a.nota end) as avg
           from all_answers a
           where
             a.id_instituicao  = ?
           group by dimension_id(a.numero)}, @institution_id])
         _labels={}
         # _colors = %w(#FFD33F #FF361E #004584  )
         _colors = theme_greyscale[:colors]
         group = result.group_by{|r| r['year'] }
         #group['2011'] = group['2010'].dup

        group.each do |year,values|
            _data =[]
           values.each do |row|
              dim = row['dim']
              labels[ dim.to_i-1 ] =  dim
              _data << row['avg'].to_f
              puts "dim: #{dim } #{year}, #{row['avg'].to_i}"
            end
            self.data year.to_s,_data, _colors.shift
         end
          minimum_value = 0
          maximum_value = 5
        #self.labels = _labels


      end

    end
  end
end

