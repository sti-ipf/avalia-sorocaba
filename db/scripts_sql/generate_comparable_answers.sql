----------------------------------------------------------------------
-- Cria tabela com respostas padronizadas por numeros de 2010
CREATE TABLE comparable_answers (
  id INTEGER NOT NULL AUTO_INCREMENT,
  external_id INTEGER  NOT NULL,
  institution_id INTEGER  NOT NULL,
  number VARCHAR(200) NOT NULL,
  original_number VARCHAR(200) NOT NULL,
  score INTEGER  NOT NULL,
  level_name VARCHAR(200) ,
  segment_name VARCHAR(200) ,
  old_segment_name VARCHAR(200) ,
  dimension INTEGER  NOT NULL,
  indicator INTEGER  NOT NULL,
  question INTEGER  NOT NULL,
  year INTEGER  NOT NULL,
  answer_date DATE  NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = MyISAM;

---Este campo foi criado depois
---ALTER TABLE `comparable_answers` ADD COLUMN `old_segment_name` VARCHAR(200) NULL  AFTER `answer_date` ;

---update comparable_answers set old_segment_name=segment_name, segment_name="Funcionários" where segment_name LIKE "Funcion%"

