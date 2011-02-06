require 'csv'
require "rubygems"
require "active_record"

ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :host => "localhost",
  :username => "root",
  :password => "root",
  :database => "ipf")


class Institution < ActiveRecord::Base
  belongs_to :group
end

class Group< ActiveRecord::Base
  has_many :institutions
end



def write_file(empresa,tipo,arquivo)
  file_name="groups/#{arquivo}"
  if File.exists?(file_name)
    my_file = File.open(file_name, "a:UTF-8")
  else
    my_file = File.new(file_name, "a:UTF-8")
  end
  my_file.puts "[#{tipo}]#{empresa}"
  puts empresa
end

def update_group_institution(institution_id,group)
  inst=Institution.find(institution_id)
  inst.group=group
  inst.save
end

NOT_FOUND_LOG="instituicao_nao_encontrada.txt"
FOUND_LOG="instituicao_encontradas.txt"

csv_files=[
["infantil.csv","Infantil"],
["infantil+EMEF integral.csv","Infantil + EMEF Integral"],
["infantil+EMEF parcial.csv","Infantil + EMEF Parcial"],
["EMEF Parcial.csv","EMEF Parcial"],
["EMEF integral.csv","EMEF Integral"],
["EMEF + medio.csv","EMEF + Medio"]
]

Group.all.each do |g|
  g.delete
end

csv_files.each do |group|
  row_number=0
  cur_group=Group.create(:name=>group[1])

  CSV.foreach("groups/#{group[0]}") do |row|
    if row_number>0
      inst=row[0].strip
      length=inst.size-8
      institution=Institution.find(:first,:conditions=>["name like ?","#{inst[0..length]}%"])
      if institution.nil?
        write_file(inst,group[1],NOT_FOUND_LOG)
      else
        write_file(institution.name,group[1],FOUND_LOG)
        institution.group=cur_group
        institution.save
      end
    end
    row_number=row_number+1
  end

end

#Atualizando escolas que nao foram detectadas


csv_files=[
["infantil.csv","Infantil"],
["infantil+EMEF integral.csv","Infantil + EMEF Integral"],
["infantil+EMEF parcial.csv","Infantil + EMEF Parcial"],
["EMEF Parcial.csv","EMEF Parcial"],
["EMEF integral.csv","EMEF Integral"],
["EMEF + medio.csv","EMEF + Medio"]
]


group_infantil=Group.find_by_name(csv_files[0][1])
update_group_institution(9,group_infantil)
update_group_institution(18,group_infantil)
update_group_institution(27,group_infantil)
update_group_institution(30,group_infantil)
update_group_institution(33,group_infantil)
update_group_institution(36,group_infantil)
update_group_institution(118,group_infantil)
update_group_institution(46,group_infantil)
update_group_institution(53,group_infantil)
update_group_institution(54,group_infantil)
update_group_institution(56,group_infantil)
update_group_institution(60,group_infantil)
update_group_institution(74,group_infantil)
update_group_institution(79,group_infantil)
update_group_institution(11,group_infantil)
update_group_institution(81,group_infantil)
update_group_institution(84,group_infantil)
update_group_institution(87,group_infantil)


group_infantil_emef_integral=Group.find_by_name(csv_files[1][1])
update_group_institution(94,group_infantil_emef_integral)
update_group_institution(28,group_infantil_emef_integral)

group_infantil_emef_parcial=Group.find_by_name(csv_files[2][1])
update_group_institution(104,group_infantil_emef_parcial)
update_group_institution(105,group_infantil_emef_parcial)

group_emef_parcial=Group.find_by_name(csv_files[3][1])
update_group_institution(112,group_infantil_emef_parcial)

group_emef_integral=Group.find_by_name(csv_files[4][1])
update_group_institution(335,group_emef_integral)
update_group_institution(362,group_emef_integral)
update_group_institution(124,group_emef_integral)
update_group_institution(125,group_emef_integral)
update_group_institution(218,group_emef_integral)
update_group_institution(245,group_emef_integral)
update_group_institution(133,group_emef_integral)
update_group_institution(115,group_emef_integral)


group_emef_medio=Group.find_by_name(csv_files[5][1])
update_group_institution(121,group_emef_medio)
update_group_institution(122,group_emef_medio)




#Instituicoes sem grupos
#- 134 e 251 - Antonio Carlos de Barros
#- 159 e 276 - Elvira Nani Monteiro
#- 271, 154, 360 e 243 | Luiz de Sanctis
#- 285, 361 e 168 | Luiz Ribeiro

