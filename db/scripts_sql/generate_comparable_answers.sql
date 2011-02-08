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

