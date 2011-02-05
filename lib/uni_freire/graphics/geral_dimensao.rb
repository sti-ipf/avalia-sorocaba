module UniFreire
  module Graphics
    class GeralDimensao < UniFreire::Graphics::Base
      def initialize(institution,dimension,size="600x300")
        super(size)
        to_id = lambda{|model| (model.is_a?(Numeric)) ? model : model.id }
        @institution_id = to_id.call(institution)
        @dimension_id   = to_id.call(dimension)
        make
      end

      def make
         # result = Answer.find_by_sql([%Q{select  segment_name,service_levels,year, avg(answer_value(zero,one,two,three,four,five)) as avg
         # from (
         #  -- gets only a question per user,question and survey_id
         #  select  segments.name as segment_name, levels.name as service_levels, year(answers.created_at) as year, answers.user_id,answers.survey_id,answers.question_id,zero,one,two,three,four,five
         #    from answers,surveys, users, segments,segments_service_levels as seg_levels, questions, institutions as inst, institutions_service_levels as islevels, service_levels as levels
         #
         #    where
         #            answers.survey_id= surveys.id and
         #            surveys.segment_id = segments.id and
         #            questions.survey_id = surveys.id and
         #            answers.question_id = questions.id and
         #
         #            inst.id = islevels.institution_id and
         #            levels.id = islevels.service_level_id and
         #
         #            seg_levels.service_level_id = levels.id and
         #            seg_levels.segment_id = segments.id and
         #            users.institution_id = inst.id and
         #            answers.user_id = users.id and
         #            inst.id  = ? and
         #            dimension_id(questions.number) = ?
         #          group by 1,2,3,4,5,6
         #          order by 1 asc
         # ) as result group by 1,2}, @institution_id, @dimension_id])
         result = Answer.find_by_sql([%Q{
           select distinct
                       a.segment_name as segment_name,
                       a.level_name as service_levels,
                       year(a.data) as year,
                       avg(case when a.nota = 6 then 0 else a.nota end) as avg
                   from all_answers a
                   where
                        a.id_instituicao = ?
                        and dimension_id(a.numero) = ?
                        and a.segment_name in ('Funcionários', 'Professores', 'Gestores', 'Funcionários de Apoio Pedagógico','Familiares')
                   group by a.segment_name, a.level_name}, @institution_id, @dimension_id])
       # _colors = %w(#FFD33F #FF361E #004584 gray )
        _colors = theme_greyscale[:colors]
         group = result.group_by{|r| r['service_levels'] }

         label_idx = 0
         group.each do |level,values|
            _data =[]
           values.each do |row|
              seg = row['segment_name']
              labels[ label_idx ] =  seg
              label_idx +=1
              _data << row['avg'].to_f

            end
            puts "#{level} #{_data.inspect}"
            self.data level,_data, _colors.shift
         end

      end

    end
  end
end

