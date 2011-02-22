require "yaml"
require "rubygems"
require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :host => "localhost",
  :username => "root",
  :password => "root",
  :database => "unifreire_sorocaba",
  :encoding => "utf8"
  )

def execute(query)
  ActiveRecord::Base.connection.execute(query)
end

def import_old_data(year)

  resps = execute("SELECT
                          i.id, r.id_dimensao, r.id_indicador, r.grau_indicador, r.data_resp, r.id_questao
                          FROM
                            ipf_sorocaba_#{year}.portal_ipf_respostas_questoes r,
                            unifreire_sorocaba.institutions i
                         where
                            r.id_escola = i.id_#{year}
                          order by i.id, r.id_dimensao, r.id_indicador")

  dim = 0
  ind = 1
  curr_ind=0
  resps.each do | resp|
#    puts "D:#{resp[1]} - I:#{resp[2]} - Q:#{resp[5]}"
#    puts "dim:#{dim} - ind:#{ind} - curr_ind=#{curr_ind}"
    if dim != resp[1]
      dim = resp[1]
      ind = 1
      curr_ind=resp[2]
    elsif curr_ind != resp[2]
      ind += 1
      curr_ind=resp[2]
    end
#    puts "POS -> dim:#{dim} - ind:#{ind} - curr_ind=#{curr_ind}"
    execute("insert into comparable_answers
     (external_id, institution_id, number, original_number, score, level_name,
     segment_name, dimension, indicator, question, year, answer_date)
    values
     (0, #{resp[0]}, '#{dim}.#{ind}.#{resp[5]}', '#{dim}.#{ind}.#{resp[5]}', #{resp[3]}, NULL, NULL, #{dim}, #{ind}, #{resp[5]}, #{year}, '#{resp[4]}')")
  end
end

execute("drop table comparable_answers")

execute("CREATE TABLE comparable_answers (id INTEGER NOT NULL AUTO_INCREMENT,
  external_id INTEGER  NOT NULL, institution_id INTEGER  NOT NULL, number VARCHAR(200) NOT NULL,
  original_number VARCHAR(200) NOT NULL, score FLOAT  NOT NULL, level_name VARCHAR(200) , segment_name VARCHAR(200) ,
  segment_order INTEGER NOT NULL, old_segment_name VARCHAR(200) , dimension INTEGER  NOT NULL,
  indicator INTEGER  NOT NULL, question INTEGER  NOT NULL, year INTEGER  NOT NULL, answer_date DATE  NOT NULL,
  PRIMARY KEY (id)) ENGINE = MyISAM")

execute("insert into comparable_answers
                                          (external_id, institution_id, number, original_number, score, level_name,
                                          segment_name, dimension, indicator, question, year, answer_date)
                                        select
                                          a.id, u.institution_id, q.number, q.number,
                                          substr(max(concat(RPAD(a.created_at,25,' '),one+(two*2)+(three*3)+(four*4)+(five*5))),26) as nota,
                                          u.service_level_id,s.name, substr(q.number,1,LOCATE('.',q.number)-1) as dimensao,
                                          substr(q.number,LOCATE('.',q.number)+1,LOCATE('.',q.number,
                                          LOCATE('.',q.number)+1) - 1 - LOCATE('.',q.number) ) as indicador,
                                          substr(q.number,LOCATE('.',q.number,LOCATE('.',q.number)+1) + 1) as questao,
                                          YEAR(MAX(a.created_at)), MAX(a.created_at)
                                          FROM answers a inner join users u on u.id=a.user_id
                                             inner join questions q on q.id = a.question_id
                                             inner join segments s on s.id = u.segment_id
                                          group by a.user_id, q.number;")

execute("update comparable_answers set year=2010 where year=2011")

execute("update comparable_answers set number=concat('1.6.',question),indicator=6 where dimension=1 and indicator=5 and year=2010")
execute("update comparable_answers set number=concat('1.5.',question),indicator=5 where dimension=1 and indicator=4 and year=2010")

execute("update comparable_answers set segment_name='Prof Infantil' where level_name=2 and segment_name like 'Profess%'")

execute("update comparable_answers set segment_name='Prof Fund \n e Médio' where level_name in (3,4) and segment_name like 'Profess%'")

execute("update comparable_answers set segment_order = 1 where segment_name='Gestores'")
execute("update comparable_answers set segment_order = 2 where segment_name='Prof Infantil'")
execute("update comparable_answers set segment_order = 3 where segment_name='Prof Fund \n e Médio'")
execute("update comparable_answers set segment_order = 4 where segment_name='Func Apoio'")
execute("update comparable_answers set segment_order = 5 where segment_name='Func Aux Educ'")
execute("update comparable_answers set segment_order = 6 where segment_name='Familiares'")
execute("update comparable_answers set segment_order = 7 where segment_name='Educandos'")




puts "Vai importar dados antigos"
import_old_data(2008)
import_old_data(2009)

#execute("ALTER TABLE comparable_answers ADD INDEX institution (institution_id ASC, dimension ASC)")
#execute("ALTER TABLE comparable_answers ADD INDEX institution_and_indicator (institution_id ASC, dimension ASC, indicator ASC, year ASC")
#execute("ALTER TABLE comparable_answers ADD INDEX institution_and_segment_name (institution_id ASC, year ASC, segment_name ASC, dimension ASC, indicator ASC, question ASC")

execute("update comparable_answers set score = 0 where score=6")

execute ("truncate institutions_service_levels")
execute ("insert into institutions_service_levels select id,2 from institutions where group_id in(61,62,63)")
execute ("insert into institutions_service_levels select id,3 from institutions where group_id in(62,63,64,65,66)")
execute ("insert into institutions_service_levels select id,4 from institutions where group_id in(66)")

execute("drop table report_data")
execute("CREATE TABLE report_data (
  institution_id int(11) NOT NULL, sum_type varchar(50) DEFAULT NULL, item_order varchar(50) DEFAULT NULL,
  segment_name varchar(50) DEFAULT NULL, segment_order int(11) DEFAULT NULL, score float DEFAULT NULL,
  dimension int(11) DEFAULT NULL, indicator int(11) DEFAULT NULL, question int(11) DEFAULT NULL
) ENGINE=MyISAM")

#execute("ALTER TABLE report_data ADD INDEX 'index_on_institution_id_and_dimension' (institution_id ASC, dimension ASC)")


execute("update comparable_answers set institution_id=159 where institution_id=276")
execute("update comparable_answers set institution_id=58 where institution_id in (168,285,361)")
execute("update comparable_answers set institution_id=57 where institution_id in (154,243,271,360)")
execute("update comparable_answers set institution_id=123 where institution_id in (218,245)")
execute("delete from institutions_year_history where institution_id in (276,168,285,361,154,243,271,360,218,245)")


execute("CREATE  TABLE `supervisor` (
  `id` INT NOT NULL ,
  `name` VARCHAR(250) NULL )")

execute("insert into supervisors (id, name) values
  (0, 'Edmara'),
  (1, 'Elaine'),
  (2, 'Paula'),
  (3, 'Sônia'),
  (4, 'Gilsemara'),
  (5, 'Ana Rosa'),
  (6, 'Aparecida'),
  (7, 'Antonio Carlos'),
  (8, 'Jessimeire'),
  (9, 'Cristina'),
  (10, 'Cláudia'),
  (11, 'Márcia'),
  (12, 'Everton'),
  (13, 'Fábio'),
  (14, 'Sara')")

execute("ALTER TABLE institutions ADD COLUMN supervisor_id INTEGER AFTER group_id")

execute("update institutions set supervisor_id = 0 where id in (104,70,106,85,105,89,50)")
execute("update institutions set supervisor_id = 1 where id in (101,74,15,54,56,128,122)")
execute("update institutions set supervisor_id = 2  where id in (107,24,78,79,30,45,123,133)")
execute("update institutions set supervisor_id = 3 where id in (19,20,32,51,114,46,56,120)")
execute("update institutions set supervisor_id = 4 where id in (87,86,16,84,52,49,72,115,110)")# 56 <jorge luiz esta em dois grupos>
execute("update institutions set supervisor_id = 5 where id in (69,62,41,132,25,75,93,121)")
execute("update institutions set supervisor_id = 6 where id in (66,48,31,58,14,91,113)")
execute("update institutions set supervisor_id = 7 where id in (98,21,73,36,124,102)")
execute("update institutions set supervisor_id = 8 where id in (90,47,57,64,77,67,126,109)")
execute("update institutions set supervisor_id = 9 where id in (18,53,44,33,65,130,111,112)")
execute("update institutions set supervisor_id = 10 where id in (108,63,12,88,92,125,99)")
execute("update institutions set supervisor_id = 11 where id in (81,39,55,37,28,22,60,127)")
execute("update institutions set supervisor_id = 12 where id in (118,35,34,11,61,83,129,119)")
execute("update institutions set supervisor_id = 13 where id in (38,100,9,96,17,103)")
execute("update institutions set supervisor_id = 14 where id in (131,29,76,71,68,59,94)")


#execute("drop table institutions_year_history")
execute ("CREATE  TABLE institutions_year_history (
  institution_id INT NOT NULL ,
  level_type INT NOT NULL,
  year INT NULL)")


execute("insert into institutions_year_history select id,2,2008 from institutions where id in (66,16,81,118,62,44,18,87,89,19,22,24,29,31,9,38,39,90,36,85,12,159,35,53,132,45,46,48,49,14,50,51,52,55,56,17,57,154,243,271,360,
58,168,285,361,59,63,64,65,68,70,30,71,47,21,32,34,37,25,27,60,61,72,11,20,83,84,88,15,33,54,69,74,75,76,77,78)")
execute("insert into institutions_year_history select id,2,2009 from institutions where id in (66,16,41,81,118,62,44,18,87,89,19,22,24,29,31,9,38,39,90,36,85,12,159,35,132,45,46,48,49,14,50,51,52,55,56,17,57,154,243,271,360,
58,168,285,361,59,63,64,65,68,70,30,71,47,21,32,34,37,25,27,60,61,72,11,20,83,84,88,15,33,54,69,74,75,76,77,78,86,67,73,79)")
execute("insert into institutions_year_history select id,2,2010 from institutions where id in (66,16,41,81,118,62,44,18,87,89,19,22,24,29,31,9,38,39,90,36,85,12,159,35,132,45,46,48,49,14,50,51,52,55,56,17,57,154,243,271,360,
58,168,285,361,59,63,64,65,68,70,30,71,47,21,32,34,37,25,27,60,61,72,11,20,83,84,88,15,33,54,69,74,75,76,77,78,86,67,73,79)")
execute("insert into institutions_year_history select id,3,2008 from institutions where id in (107,104,28,106,100,110,105,96,131,98,108,114,101,123,133,218,245,91,124,125,126,93,127,128,122,103,121,115,94,130,109,120,111,112,113,129,99,133,102,119)")
execute("insert into institutions_year_history select id,3,2009 from institutions where id in (107,104,28,106,100,110,105,96,131,98,108,114,101,92,123,133,218,245,91,124,125,126,93,127,128,122,103,121,115,94,130,109,120,111,112,113,129,99,133,102,119)")
execute("insert into institutions_year_history select id,3,2010 from institutions where id in (107,104,28,106,100,110,105,96,131,98,108,114,101,92,123,133,218,245,91,124,125,126,93,127,128,122,103,121,115,94,130,109,120,111,112,113,129,99,133,102,119)")


execute("ALTER TABLE institutions ADD COLUMN infantil_type INTEGER AFTER group_id;")
#Infantil Integral
execute("UPDATE institutions SET infantil_type = 3 WHERE id IN (16,89,22,45,46,49,50,52,56,17,68,30,21,34,25,27,60,61,11,83,88,15,33,75,77,67,33)")
#Infantil Parcial
execute("UPDATE institutions SET infantil_type = 2 WHERE id IN (81,118,62,18,19,24,29,31,9,38,39,90,85,12,35,53,55,57,154,243, 271,360,
                      58,168,285,361,64,70,71,47,32,37,20,84,74,76,78)")
#Integral + Parcial
execute("UPDATE institutions SET infantil_type = 1 WHERE id IN (66,41,44,87,36,132,48,14,51,59,63,65,72,54,69,86,73,79)")


execute("ALTER TABLE institutions ADD COLUMN primary_service_level_id INTEGER AFTER group_id;")
execute("UPDATE institutions SET primary_service_level_id = 3 WHERE id IN (122, 108, 109, 112, 130, 111, 99, 92, 125, 127, 128, 105, 101, 93, 115, 104, 106, 100, 124, 103, 94, 96, 98, 102, 126, 28, 131, 119, 121, 120, 113, 123, 107, 114, 91, 129, 110, 133)")
execute("UPDATE institutions SET primary_service_level_id = 2 WHERE id NOT IN (122, 108, 109, 112, 130, 111, 99, 92, 125, 127, 128, 105, 101, 93, 115, 104, 106, 100, 124, 103, 94, 96, 98, 102, 126, 28, 131, 119, 121, 120, 113, 123, 107, 114, 91, 129, 110, 133)")
execute("ALTER TABLE comparable_answers CHANGE old_segment_name new_segment_name varchar(200);")
execute("ALTER TABLE comparable_answers ADD COLUMN new_segment_order INTEGER AFTER answer_date;")
execute("UPDATE comparable_answers set new_segment_name = segment_name;")
execute("UPDATE comparable_answers set new_segment_order = segment_order;")
execute("update comparable_answers set new_segment_name='Funcionários', new_segment_order=4  where new_segment_name like 'Func%';")
execute("update comparable_answers set new_segment_name='Professores', new_segment_order=2 where new_segment_name like 'Prof%';")
execute("ALTER TABLE institutions ADD COLUMN alias varchar(255) AFTER primary_service_level_id;")
result = execute("select id from institutions")
result.each do |r|
  id = r[0]
  i_alias = I18n.t("institutions.i#{id}")
  if !i_alias.include?("translation missing")
    execute("UPDATE institutions SET alias = '#{i_alias}' WHERE id = #{id}")
  end
end

