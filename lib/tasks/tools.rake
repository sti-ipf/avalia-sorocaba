ORIGINAL_FILES_DIRECTORY = File.expand_path "#{RAILS_ROOT}/lib/uni_freire/reports/relatorio_individual_sorocaba/original_files"
TEMPLATE_DIRECTORY= File.expand_path "#{RAILS_ROOT}/lib/uni_freire/reports/relatorio_individual_sorocaba/template"
require 'pathname'
namespace :tools do
  namespace :generate do
    namespace :template do
      desc "Receives a pdf file to create a template, usage (absolute path) FILE=/tmp/myfile.pdf"
      #you should have pdftopdf and pdftk in your vm
      task :one_page do
        abort "FILE and PAGE is mandatody" if ENV['FILE'].nil?  || ENV['PAGE'].nil?
        source_file = if (Pathname.new ENV['FILE']).absolute?
                        ENV['FILE']
                      else
                        File.join(ORIGINAL_FILES_DIRECTORY,ENV['FILE'])
                      end
        page =  ENV['PAGE']
        source_file_name = source_file[(source_file.rindex("/")+1)..(source_file.rindex(".pdf")-1)]
        eps_file = File.join(TEMPLATE_DIRECTORY,source_file_name)
        `pdftops -eps -f #{page} -l #{page} #{source_file} #{eps_file}.eps 1> /dev/null 2> /dev/null`
      end
      
      task :many_pages do
        source_file = if (Pathname.new ENV['FILE']).absolute?
                        ENV['FILE']
                      else
                        File.join(ORIGINAL_FILES_DIRECTORY,ENV['FILE'])
                      end
        page_start =  ENV['PAGE_START'].to_i
        page_end   =  ENV['PAGE_END'].to_i
        abort "FILE is mandatody" unless source_file
        
        (page_start..page_end).each do |i|
          eps_file = File.join(TEMPLATE_DIRECTORY,"pg_00")
          page_number = "0#{i}" if i.size == 1
          `pdftops -eps -f #{i} -l #{i} #{source_file} #{eps_file}#{page_number}.eps 1> /dev/null 2> /dev/null`
        end

      end
      
    end
  end
end
