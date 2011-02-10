---Este campo foi criado depois
---ALTER TABLE `comparable_answers` ADD COLUMN `old_segment_name` VARCHAR(200) NULL  AFTER `answer_date` ;

---Atualizamos todos os nomes dos segmentos para agrupar os funcionarios
update comparable_answers set segment_order = 1 where segment_name="Gestores";
update comparable_answers set segment_order = 2 where segment_name="Professores";
update comparable_answers set segment_order = 3 where segment_name="Func. Apoio";
update comparable_answers set segment_order = 4 where segment_name="Func. Aux. Educ.";
update comparable_answers set segment_order = 5 where segment_name="Familiares";
update comparable_answers set segment_order = 6 where segment_name="Educandos";

