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
      indicators_where = "numero = '#{old_indicator}'"
  else
    return nil
  end
  "insert into comparable_answers
  (external_id, institution_id, number, original_number, score, level_name,
  segment_name, dimension, indicator, question, year, answer_date)
  select external_id, id_instituicao, '#{new_indicator}', '#{indicators_get}', avg(nota), null, null, #{ids[0]}, #{ids[1]}, #{ids[2]}, year(data), data
    from dados_#{year}
    where
      year(data) = #{year}
      and (#{indicators_where})
    group by id_instituicao"
end

ActiveRecord::Base.connection.execute("truncate comparable_answers")
ActiveRecord::Base.connection.execute("insert into comparable_answers
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

dt = YAML::load(File.open("config/data_transformations.yml"))
dt.each_pair do |key, value|
  new_indicator = "#{key[7..key.size]}"
  query = generate_query(new_indicator, 2009, value[2009])
  puts "Indicator:#{new_indicator}, 2009:#{value[2009]}"
  puts "Query:#{query}"
  ActiveRecord::Base.connection.execute(query) unless query.nil?

  query = generate_query(new_indicator, 2008, value[2008])
  puts "Indicator:#{new_indicator}, 2008:#{value[2008]}"
  puts "Query:#{query}"
  ActiveRecord::Base.connection.execute(query) unless query.nil?

  query = "update comparable_answers set old_segment_name=segment_name"
  puts "Query:#{query}"
  ActiveRecord::Base.connection.execute(query) unless query.nil?

  query = "update comparable_answers set segment_name='Funcionários' where segment_name LIKE 'Funcion%'"
  puts "Query:#{query}"
  ActiveRecord::Base.connection.execute(query) unless query.nil?

end

