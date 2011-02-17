

1.1. Série Histórica


a) Série Histórica dos Resultados por dimensão


a - Infantil
SELECT dimension,year, avg(media) as new_media from
(SELECT ca.dimension as dimension, ca.indicator as indicator,
ca.year as year, AVG(ca.score) AS media
FROM   comparable_answers ca
INNER JOIN institutions_service_levels isl ON isl.institution_id = ca.institution_id
WHERE  score > 0 and isl.service_level_id = 2
GROUP BY dimension, indicator, year) a
GROUP BY dimension,year



b - Fundamental
SELECT dimension,year, avg(media) as new_media from
(SELECT ca.dimension as dimension, ca.indicator as indicator,
ca.year as year, AVG(ca.score) AS media
FROM   comparable_answers ca
INNER JOIN institutions_service_levels isl ON isl.institution_id = ca.institution_id
WHERE  score > 0 and isl.service_level_id in (3,4)
GROUP BY dimension, indicator, year) a
GROUP BY dimension,year





b ) Gráficos da série histórica dos resultados por indicador

Para cada dimensão:
SELECT ca.dimension as dimension, ca.indicator as indicator,
ca.year as year, AVG(ca.score) AS media
FROM   comparable_answers ca
INNER JOIN institutions_service_levels isl ON isl.institution_id = ca.institution_id
WHERE  score > 0 and isl.service_level_id = 2 and dimension = 1
GROUP BY dimension, indicator, year


Em dimensões onde um determinado indicador não deva ser mostrado

Infantil
SELECT ca.dimension as dimension, ca.indicator as indicator,  ca.year as year, AVG(ca.score) AS media
FROM   comparable_answers ca  INNER JOIN institutions_service_levels isl
ON isl.institution_id = ca.institution_id
WHERE  score > 0 and isl.service_level_id = 2 and dimension = 2 and indicator <> 7 GROUP BY dimension, indicator, year;





3.1. Análise dos resultados por dimensões e indicadores da Educação Infantil e Ensino Fundamental

DELETE FROM report_data WHERE institution_id = 0;

insert into report_data
        select 0,"Educação Infantil",1,segment_name,segment_order,
            avg(score) as media,dimension,indicator,question
        from comparable_answers ca INNER JOIN institutions_service_levels isl
        ON isl.institution_id = ca.institution_id
        where isl.service_level_id = 2 and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question;



insert into report_data
        select 0,"Educação Fundamental",2,segment_name,segment_order,
            avg(score) as media,dimension,indicator,question
        from comparable_answers ca INNER JOIN institutions_service_levels isl
        ON isl.institution_id = ca.institution_id
        where isl.service_level_id in (3,4) and year=2010 and segment_name <> 'Alessandra' group by segment_name,dimension,indicator,question;



update report_data set segment_name="Funcionários", segment_order=4 where segment_name like "Func%";
update report_data set segment_name="Professores", segment_order=2 where segment_name like "Prof%";

delete from report_data where segment_name = "Educandos" and item_order=1;

insert into report_data
        select 0,"Educação Infantil",1,"Média",0,
            avg(score) as media,dimension,indicator,question
        from report_data where item_order=1
        group by dimension,indicator,question;

insert into report_data
        select 0,"Educação Fundamental",2,"Média",0,
            avg(score) as media,dimension,indicator,question
        from report_data where item_order=2
        group by dimension,indicator,question;


#Apagando indicadores que não deverao ser considerados no relatorio
delete from report_data where dimension=2 and indicator=7 and item_order=1
Faltam outros indicadores e dimensoes...


A) Grafico da dimensao

          SELECT segment_name,sum_type,AVG(media) as new_media from
          (SELECT segment_name,
                 item_order,
                 segment_order,
                 sum_type, indicator,
                 AVG(score) AS media
          FROM   report_data
          WHERE  dimension = 1
                 AND score > 0
          GROUP  BY segment_order, item_order,indicator) a
          GROUP BY segment_order, item_order


B) Grafico do indicador

          SELECT segment_name,sum_type,AVG(media) as new_media from
          (SELECT segment_name,
                 item_order,
                 segment_order,
                 sum_type, indicator,
                 AVG(score) AS media
          FROM   report_data
          WHERE  dimension = 1
                 AND indicator = 1
                 AND score > 0
          GROUP  BY segment_order, item_order,indicator) a
          GROUP BY segment_order, item_order

