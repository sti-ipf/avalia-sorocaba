

require 'rubygems'
require File.dirname(__FILE__)+'/../../config/environment'
require "resque"


Rails.configuration.log_level = :info # Disable debug
ActiveRecord::Base.allow_concurrency = true

ENV["PATH"] = "/usr/local/bin/:/opt/local/bin:#{ENV["PATH"]}"

namespace :vizir do
  namespace :generate do

    task:one do
      puts "Vai Gerar Relatório"
      UniFreire::Reports::RelatorioIndividualSoracaba.new(72).report
      puts "Geratório gerado na pasta public"
    end

    task:all do
      puts "Criando tudo"
      Resque.enqueue(Generationq,1)
    end
  end
end

