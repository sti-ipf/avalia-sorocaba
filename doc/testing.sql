#tabela dados_2008 e dados_2008 ja esta na estrutura de all_answers


#migra os dados 2010 pra all_answers
select  answers.id as external_id, inst.id as id_instituicao, questions.number as numero, answer_value(zero,one,two,three,four,five) as nota,
 
cast('2010-12-15' as date) as data, levels.name as service_levels, segments.name as segment_name
-- select count(*)   
  from answers,surveys, users, segments,segments_service_levels as seg_levels, questions, institutions as inst, institutions_service_levels as islevels, service_levels as levels

    where 
	  answers.survey_id= surveys.id and 
      answers.user_id = users.id and
	  answers.question_id = questions.id and 

	  surveys.segment_id = segments.id and 
 	  users.institution_id = inst.id  and

	  questions.survey_id = surveys.id and 
	  
	  inst.id = islevels.institution_id and 
	  levels.id = islevels.service_level_id and 
	  
	  seg_levels.service_level_id = levels.id and
	  seg_levels.segment_id = segments.id  

	  

	 -- and inst.id  = 133
	-- group by 1,2,3,4,5,6
	order by 1 asc -- limit 1000
-- distinct 130.215
-- count 146.479
-- all 162.554
-- select count(*) from answers -- 146.479