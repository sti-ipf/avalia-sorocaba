---Este campo foi criado depois
---ALTER TABLE `comparable_answers` ADD COLUMN `old_segment_name` VARCHAR(200) NULL  AFTER `answer_date` ;

---Atualizamos todos os nomes dos segmentos para agrupar os funcionarios
update comparable_answers set old_segment_name=segment_name, segment_name="Funcionários" where segment_name LIKE "Funcion%"

