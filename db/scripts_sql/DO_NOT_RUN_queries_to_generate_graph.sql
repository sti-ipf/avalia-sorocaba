
####################################################################
#  Rodar antes de executar as queries para criar a tabela #
####################################################################


####################################################################
#1.2. Gráfico geral da série histórica dos resultados das dimensões#
####################################################################

select dimension,year,avg(score) as media  from comparable_answers where institution_id=72 group by dimension,year;

####################################################################
# 1.3. Gráficos da série histórica dos resultados dos indicadores  #
####################################################################

select dimension,indicator,year,avg(score) as media from comparable_answers where institution_id=72 and dimension=2 group by indicator,year;


####################################################################
#   2.2.1 Gráfico Geral da dimensão                                #
####################################################################

* Criara os dados na tabela report_data e depois os relatorios consomem esta tabela.

delete from report_data where institution_id=72


* Calculo da media da UE

insert into report_data select institution_id,'média da UE',1,segment_name,avg(score) as media,dimension,indicator,question
from comparable_answers where institution_id=72 and year=2010 and segment_name <> "Alessandra" group by segment_name,indicator,question;


* Calculo da media da Ed. Infantil       *

insert into report_data
select 72,'média da Ed. Infantil',2,segment_name,avg(score) as media,dimension,indicator,question  from comparable_answers
where year=2010  and segment_name <> "Alessandra"  and level_name = 2
group by segment_name,question;


* Calculo da media do Ensino Fundamental *

insert into report_data
select 72,'média do Ensino Fundamental',3,segment_name,avg(score) as media,dimension,indicator,question  from comparable_answers
 where year=2010  and segment_name <> "Alessandra" and level_name in (3,4)
 group by segment_name,question;


* Calculo da media do agrupamento

insert into report_data
select 72,'média do agrupamento',4,segment_name,avg(score) as media,dimension,indicator,question
from comparable_answers ca inner join institutions i on i.id=ca.institution_id
where i.group_id=(select group_id from institutions where id=72) and ca.year=2010  and ca.segment_name <> "Alessandra"
group by ca.segment_name,ca.question;

* Calculo da media da regiao

insert into report_data
select 72,'média da região',5,segment_name,avg(score) as media,dimension,indicator,question
from comparable_answers ca inner join institutions i on i.id=ca.institution_id
where i.region_id=(select region_id from institutions where id=72) and ca.year=2010  and ca.segment_name <> "Alessandra"
group by ca.segment_name,ca.question;


####################################################################
         Select para o gráfico geral da dimensão
####################################################################

select segment_name,sum_type,avg(score) as media from report_data where institution_id=72 and dimension=1 group by segment_name,item_order


####################################################################
         Select para o gráfico do indicador
####################################################################

select segment_name,question,sum_type,avg(score) as media from report_data where institution_id=72 and dimension=1 group by segment_name,question,item_order


####################################################################
      Query para pegar a quantidade de indicadores
####################################################################
select count(*) from
(select indicator from comparable_answers
where dimension=1 and institution_id=72 group by indicator) a;

