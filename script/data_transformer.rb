require "yaml"

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

dt = YAML::load(File.open("config/data_transformations.yml"))
dt.each_pair do |key, value|
  new_indicator = "#{key[7..key.size]}"
  query = generate_query(new_indicator, 2009, value[2009])
  puts "Indicator:#{new_indicator}, 2009:#{value[2009]}"
  puts "Query:#{query}"

  query = generate_query(new_indicator, 2008, value[2008])
  puts "Indicator:#{new_indicator}, 2008:#{value[2008]}"
  puts "Query:#{query}"
end

