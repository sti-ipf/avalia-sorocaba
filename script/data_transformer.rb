require "yaml"
require "rubygems"
require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :host => "localhost",
  :username => "root",
  :password => "root",
  :database => "ipf")


def generate_query(new_indicator, year, old_indicator)
  ids = new_indicator.split(".")
  if(old_indicator.class == Array)
    indicators_get = old_indicator.join(" + ")
    indicators_where = ""
    old_indicator.each do |v|
      indicators_where += "numero = '#{v}' or "
    end
    indicators_where = indicators_where[0 .. indicators_where.size - 5]
  elsif(old_indicator.class == String && old_indicator != "")
      indicators_get = old_indicator
      indicators_where = "numero like '#{old_indicator}%'"
  else
    return nil
  end
  "insert into comparable_answers
  (external_id, institution_id, number, original_number, score, level_name,
  segment_name, dimension, indicator, question, year, answer_date)
  select external_id, id_instituicao, '#{new_indicator}', '#{indicators_get}', avg(nota), null, null, #{ids[0]}, #{ids[1]}, 0, year(data), data
    from dados_#{year}
    where
      year(data) = #{year}
      and (#{indicators_where})
      and nota > 0 and nota < 6
    group by id_instituicao"
end

def execute(query)
  ActiveRecord::Base.connection.execute(query)
end

execute("drop table comparable_answers")

execute("CREATE TABLE comparable_answers (id INTEGER NOT NULL AUTO_INCREMENT,
  external_id INTEGER  NOT NULL, institution_id INTEGER  NOT NULL, number VARCHAR(200) NOT NULL,
  original_number VARCHAR(200) NOT NULL, score INTEGER  NOT NULL, level_name VARCHAR(200) , segment_name VARCHAR(200) ,
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


execute("update comparable_answers set segment_name='Prof Infantil' where level_name=2 and segment_name like 'Profess%'")

execute("update comparable_answers set segment_name='Prof Fund' where level_name in (3,4) and segment_name like 'Profess%'")

execute("update comparable_answers set segment_order = 1 where segment_name='Gestores'")
execute("update comparable_answers set segment_order = 2 where segment_name='Prof Infantil'")
execute("update comparable_answers set segment_order = 3 where segment_name='Prof Fund'")
execute("update comparable_answers set segment_order = 4 where segment_name='Func Apoio'")
execute("update comparable_answers set segment_order = 5 where segment_name='Func Aux Educ'")
execute("update comparable_answers set segment_order = 6 where segment_name='Familiares'")
execute("update comparable_answers set segment_order = 7 where segment_name='Educandos'")

dt = YAML::load(File.open("config/data_transformations.yml"))
dt.each_pair do |key, value|
  new_indicator = "#{key[7..key.size]}"
  query = generate_query(new_indicator, 2009, value[2009])
  puts "Indicator:#{new_indicator}, 2009:#{value[2009]}"
  puts "Query:#{query}"
  execute(query) unless query.nil?

  query = generate_query(new_indicator, 2008, value[2008])
  puts "Indicator:#{new_indicator}, 2008:#{value[2008]}"
  puts "Query:#{query}"
  execute(query) unless query.nil?

end

#execute("ALTER TABLE comparable_answers ADD INDEX institution (institution_id ASC, dimension ASC)")
#execute("ALTER TABLE comparable_answers ADD INDEX institution_and_indicator (institution_id ASC, dimension ASC, indicator ASC, year ASC")
#execute("ALTER TABLE comparable_answers ADD INDEX institution_and_segment_name (institution_id ASC, year ASC, segment_name ASC, dimension ASC, indicator ASC, question ASC")

execute("drop table report_data")
execute("CREATE TABLE report_data (
  institution_id int(11) NOT NULL, sum_type varchar(50) DEFAULT NULL, item_order varchar(50) DEFAULT NULL,
  segment_name varchar(50) DEFAULT NULL, segment_order int(11) DEFAULT NULL, score float DEFAULT NULL,
  dimension int(11) DEFAULT NULL, indicator int(11) DEFAULT NULL, question int(11) DEFAULT NULL
) ENGINE=MyISAM")

#execute("ALTER TABLE report_data ADD INDEX 'index_on_institution_id_and_dimension' (institution_id ASC, dimension ASC)")

