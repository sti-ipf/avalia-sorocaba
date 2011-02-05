
####################################################################
#  Rodar antes de executar as queries para criar a tabela #
####################################################################

CREATE TABLE `report_data` (
  `institution_id` int(11) NOT NULL,
  `sum_type` int(11) DEFAULT NULL,
  `segment_name` varchar(50) DEFAULT NULL,
  `score` float DEFAULT NULL,
  `dimension` int(11) DEFAULT NULL,
  `indicator` int(11) DEFAULT NULL,
  `question` int(11) DEFAULT NULL
) ENGINE=MyISAM



####################################################################
#1.2. Gráfico geral da série histórica dos resultados das dimensões#
####################################################################

select dimension,year,sum(score) / count(*) as media  from comparable_answers where institution_id=72 group by dimension,year;

####################################################################
# 1.3. Gráficos da série histórica dos resultados dos indicadores  #
####################################################################

select dimension,indicator,year,sum(score) / count(*) as media from comparable_answers where institution_id=72 and dimension=2 group by indicator,year;


####################################################################
#   2.2.1 Gráfico Geral da dimensão                                #
####################################################################

* Criara os dados na tabela report_data e depois os relatorios consomem esta tabela.

delete from report_data where instituicao_id=72


* Calculo da media da UE

insert into report_data select id_instituicao,1,segment_name,sum(nota) / count(*) as media,dimensao,indicador,questao  from all_answers where id_instituicao=72 and ano=2010 and segment_name <> "Alessandra" and dimensao=1 group by segment_name,indicador,questao;



* Calculo da media da Ed. Infantil

insert into report_data select id_instituicao,2,segment_name,sum(nota) / count(*) as media,dimensao,indicador,questao  from all_answers where id_instituicao=72 and ano=2010  and segment_name <> "Alessandra" and dimensao=1 and level_name LIKE "%Infantil" group by segment_name,questao;


* Calculo da media do Ensino Fundamental

select id_instituicao,3,segment_name,sum(nota) / count(*) as media,dimensao,indicador,questao  from all_answers where id_instituicao=72 and ano=2010  and segment_name <> "Alessandra" and dimensao=1 and level_name LIKE "%Fundamental" group by segment_name,questao;


* Calculo da media do agrupamento


* Calculo da media da regiao



####################################################################
         Select para o gráfico geral da dimensão
####################################################################

select segment_name,sum_type,sum(score)/count(*) from report_data where institution_id=72 and dimension=1 group by segment_name,sum_type


####################################################################
         Select para o gráfico do indicador
####################################################################

select segment_name,sum_type,sum(score)/count(*),question from report_data where institution_id=72 and dimension=1 group by segment_name,question,sum_type

