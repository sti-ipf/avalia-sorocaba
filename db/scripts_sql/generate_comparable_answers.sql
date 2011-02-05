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
  dimension INTEGER  NOT NULL,
  indicator INTEGER  NOT NULL,
  question INTEGER  NOT NULL,
  year INTEGER  NOT NULL,
  answer_date DATE  NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = MyISAM;

----------------------------------------------------------------------
-- Inicio das queries de transformação dos dados
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Query para transformar as respostas 1.2.1 de 2008 e 2009 para 1.1.1
-- pois é o numero equivalente em 2010
insert into comparable_answers 
  (external_id, institution_id, number, original_number, score, level_name,
  segment_name, dimension, indicator, question, year, answer_date)  
  select external_id, id_instituicao, '1.1.1', '1.1.2', nota, level_name, segment_name, 1, 1, 1, ano, data
    from all_answers
      where 
        numero = '1.1.2'
        and (ano = 2008 OR ano = 2009)
----------------------------------------------------------------------
			
			
