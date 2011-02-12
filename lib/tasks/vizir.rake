

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

  namespace :resque do
    task:one, :id do |t,args|
      puts "Vai Gerar Relatório via Resque"
      if args[:id].nil?
        puts "É preciso fornecer o ID da instituição"
      else
        id = args[:id]
        Resque.enqueue(Generationq,id)
        puts "Geratório enviado para o Resque"
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
                            on i.id=ca.institution_id where ca.institution_id > 60 order by institution_id")
  end

end

