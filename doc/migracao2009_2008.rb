#ActiveRecord::Base.establish_connection :sorocaba2009
ActiveRecord::Base.establish_connection :sorocaba2008

class Mock < ActiveRecord::Base 
  set_primary_key 'id_indicador'
  #set_primary_key 'id_questao'
  #set_table_name 'portal_ipf_indicadores'
  set_table_name 'portal_ipf_questoes'
end
indicadores = Mock.find :all
group = indicadores.group_by{|r| r.id_dimensao}
group.each do |k,data|
  data.each_with_index do |d,i|
    puts "#{k}.#{i+1} <<< "
    d.update_attributes :numero => "#{k}.#{i+1}"
  end
  
end

questoes = Mock.find :all
#
questoes = Mock.find_by_sql "select i.numero as n, q.numero, q.id_indicador from portal_ipf_questoes q, portal_ipf_indicadores i where
i.id_indicador = q.id_indicador order by 2"

#questoes.each{|q| q.numero = q['n']; q.save}

group = questoes.group_by{|r| r.id_indicador}
group.each do |k,data|
  data.each_with_index do |d,i|
    puts "#{d.numero}.#{i+1} <<< "
    d.update_attributes :numero => "#{d.numero}.#{i+1}"
  end
  
end

