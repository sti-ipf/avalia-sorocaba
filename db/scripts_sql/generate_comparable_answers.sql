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

insert into comparable_answers
  (external_id, institution_id, number, original_number, score, level_name,
  segment_name, dimension, indicator, question, year, answer_date)
values (select a.id, u.institution_id, q.number, q.number,
substr(concat(RPAD(a.created_at,25,' '),one+(two*2)+(three*3)+(four*4)+(five*5)),26) as nota,
u.service_level_id,s.name, substr(q.number,1,LOCATE(".",q.number)-1) as dimensao,
substr(q.number,LOCATE(".",q.number)+1,LOCATE(".",q.number,
LOCATE(".",q.number)+1) - 1 - LOCATE(".",q.number) ) as indicador,
substr(q.number,LOCATE(".",q.number,LOCATE(".",q.number)+1) + 1) as questao,
 YEAR(MAX(a.created_at)), MAX(a.created_at)
 from answers a inner join users u on u.id=a.user_id
 inner join questions q on q.id = a.question_id
 inner join segments s on s.id = u.segment_id
 group by a.user_id, q.number);

