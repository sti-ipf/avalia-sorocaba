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
                          i.id, r.id_dimensao, r.id_indicador, avg(r.grau_indicador), r.data_resp
                          FROM
                            ipf_sorocaba_#{year}.portal_ipf_respostas_questoes r,
                            unifreire_sorocaba.institutions i
                         where
                            r.id_escola = i.id_#{year}
                            and r.grau_indicador <> 6
                          group by i.id, r.id_dimensao, r.id_indicador
                          order by i.id, r.id_dimensao, r.id_indicador")

  dim = 0
  ind = 1
  resps.each do | resp|
    if dim != resp[1]
      dim = resp[1]
      ind = 1
    else
      ind += 1
    end
    execute("insert into comparable_answers
     (external_id, institution_id, number, original_number, score, level_name,
     segment_name, dimension, indicator, question, year, answer_date)
    values
     (0, #{resp[0]}, '#{dim}.#{ind}', '#{dim}.#{ind}', #{resp[3]}, NULL, NULL, #{dim}, #{ind}, 0, #{year}, '#{resp[4]}')")
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
                                          substr(concat(RPAD(a.created_at,25,' '),one+(two*2)+(three*3)+(four*4)+(five*5)),26) as nota,
                                          u.service_level_id,s.name, substr(q.number,1,LOCATE('.',q.number)-1) as dimensao,
                                          substr(q.number,LOCATE('.',q.number)+1,LOCATE('.',q.number,
                                          LOCATE('.',q.number)+1) - 1 - LOCATE('.',q.number) ) as indicador,
                                          substr(q.number,LOCATE('.',q.number,LOCATE('.',q.number)+1) + 1) as questao,
                                          YEAR(MAX(a.created_at)), MAX(a.created_at)
                                          FROM answers a inner join users u on u.id=a.user_id
                                             inner join questions q on q.id = a.question_id
                                             inner join segments s on s.id = u.segment_id
                                          group by a.user_id, q.number;")

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

execute("UPDATE institutions SET primary_service_level_id = 3 WHERE id IN (122, 108, 109, 112, 130, 111, 99, 92, 125, 127, 128, 105, 101, 93, 115, 104, 106, 100, 124, 103, 94, 96, 98, 102, 126, 28, 131, 119, 121, 120, 113, 123, 107, 114, 91, 129, 110, 133)")
execute("UPDATE institutions SET primary_service_level_id = 2 WHERE id NOT IN (122, 108, 109, 112, 130, 111, 99, 92, 125, 127, 128, 105, 101, 93, 115, 104, 106, 100, 124, 103, 94, 96, 98, 102, 126, 28, 131, 119, 121, 120, 113, 123, 107, 114, 91, 129, 110, 133)")
execute("ALTER TABLE institutions ADD COLUMN primary_service_level_id INTEGER AFTER group_id;")

