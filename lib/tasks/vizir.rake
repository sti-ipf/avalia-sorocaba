require 'rubygems'
require File.dirname(__FILE__)+'/../../config/environment'
require "resque"


Rails.configuration.log_level = :info # Disable debug
ActiveRecord::Base.allow_concurrency = true

ENV["PATH"] = "/usr/local/bin/:/opt/local/bin:#{ENV["PATH"]}"

namespace :generate do

  task:one, :id do |t,args|
    puts "Vai Gerar Relatório"
    if args[:id].nil?
      puts "É preciso fornecer o ID da instituição"
    else
      id = args[:id]
      UniFreire::Reports::RelatorioIndividualSoracaba.new(id).report
      puts "Relatório gerado na pasta public"
    end
  end

  task:all do
    puts "Gerando todos os relatórios. Vai demorar!"
    get_institutions_that_has_answers.each do |r|
      puts "Gerando o relatório para a instituição #{r[0]}"
      UniFreire::Reports::RelatorioIndividualSoracaba.new(r[0]).report
      puts "Relatório para a instituição gerado #{r[0]}"
    end
    puts "Todos os relatórios foram gerados"
  end

  task:set do
    puts "Gerando os relatórios para teste. Vai demorar!"
    #inst = [93,96,127,129,123,39,132,118,58,101,99,126,86]
    inst = [101,99,126,86]

    inst.each do |r|
      puts "Gerando o relatório para a instituição #{r}"
      UniFreire::Reports::RelatorioIndividualSoracaba.new(r).report
      puts "Relatório para a instituição gerado #{r}"
    end
    puts "Todos os relatórios foram gerados"
  end


  task:geral do
    puts "Vai Gerar Relatório"
    UniFreire::Reports::RelatorioGeralSorocaba.new.report
    puts "Relatório gerado na pasta public"
  end

  namespace :resque do
    task:one, :id do |t,args|
      puts "Vai Gerar Relatório via Resque"
      if args[:id].nil?
        puts "É preciso fornecer o ID da instituição"
      else
        id = args[:id]
        Resque.enqueue(Generationq,id)
        puts "Relatório enviado para o Resque"
      end
    end

    task:all do
      puts "Colocando todos os relatórios na fila do Resque"
      get_institutions_that_has_answers.each do |r|
        puts "Colocando o id #{r[0]} na fila"
        Resque.enqueue(Generationq,r[0])
      end
      puts "Todos os relatórios estão na fila"
    end
  end

  def get_institutions_that_has_answers()
    ActiveRecord::Base.connection.execute("select distinct ca.institution_id
                            from comparable_answers ca inner join institutions i
                            on i.id=ca.institution_id order by institution_id")
  end

  namespace :maps do

    task:all do
      generate_infant_map
      generate_groups_map
      generate_regions_map
      generate_supervisors_map
    end

    task:infant do
      generate_infant_map
    end

    task:groups do
      generate_groups_map
    end

    task:regions do
      generate_regions_map
    end

    task:supervisors do
      generate_supervisors_map
    end

  end

  private

    def get_data(table)
      result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table}")
      parser_data(result)
    end

    def get_groups_without_infant
      result = ActiveRecord::Base.connection.execute("
        SELECT id FROM groups WHERE id NOT IN (61)")
      parser_data(result)
    end

    def parser_data(result)
      data = []
      result.each{|r| data << r[0]}
      data
    end

    def generate_infant_map
      puts "Gerando mapa infantil"
      UniFreire::Graphics::MapaInfantil.create
      puts "Mapa infantil gerado"
    end

    def generate_groups_map
      groups = get_groups_without_infant
      groups.each do |group_id|
        puts "Gerando mapa do grupo #{group_id}"
        UniFreire::Graphics::MapaGrupos.create(group_id)
        puts "Mapa do grupo #{group_id} gerado"
      end
    end

    def generate_regions_map
      regions = get_data("regions")
      regions.each do |region_id|
        puts "Gerando mapa da região #{region_id}"
        UniFreire::Graphics::MapaRegioes.create(region_id)
        puts "Mapa da região #{region_id} gerado"
      end
    end

    def generate_supervisors_map
      supervisors = get_data("supervisors")
      supervisors.each do |supervisor_id|
        puts "Gerando mapa do supervisor #{supervisor_id}"
        UniFreire::Graphics::MapaSupervisores.create(supervisor_id)
        puts "Mapa do supervisor #{supervisor_id} gerado"
      end
    end

end

